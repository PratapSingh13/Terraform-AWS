// modules/iam/iam-user/test/iam_user_test.go
package test

import (
	"fmt"
	"testing"
	"time"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/iam"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// ─────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────

func newIAMClient(t *testing.T, region string) *iam.IAM {
	sess, err := session.NewSession(&aws.Config{
		Region: aws.String(region),
	})
	require.NoError(t, err)
	return iam.New(sess)
}

func terraformOptions(t *testing.T, vars map[string]interface{}) *terraform.Options {
	return terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "./fixtures",
		Vars:         vars,
		RetryableTerraformErrors: map[string]string{
			".*ThrottlingException.*": "AWS API throttling, retrying...",
			".*RequestError.*":        "AWS request error, retrying...",
		},
		MaxRetries:         3,
		TimeBetweenRetries: 5 * time.Second,
	})
}

// ─────────────────────────────────────────────
// Test 1: IAM users are created with correct names
// ─────────────────────────────────────────────

func TestIAMUsersCreated(t *testing.T) {
	t.Parallel()

	opts := terraformOptions(t, map[string]interface{}{
		"users": map[string]interface{}{
			"test-alice": map[string]interface{}{
				"console_access":  false,
				"pgp_key":         nil,
				"password_length": 20,
			},
			"test-bob": map[string]interface{}{
				"console_access":  false,
				"pgp_key":         nil,
				"password_length": 20,
			},
		},
	})

	defer terraform.Destroy(t, opts)
	terraform.InitAndApply(t, opts)

	iamClient := newIAMClient(t, "us-east-1")

	for _, userName := range []string{"test-alice", "test-bob"} {
		t.Run(fmt.Sprintf("user_%s_exists", userName), func(t *testing.T) {
			output, err := iamClient.GetUser(&iam.GetUserInput{
				UserName: aws.String(userName),
			})
			require.NoError(t, err)
			assert.Equal(t, userName, aws.StringValue(output.User.UserName))
		})
	}
}

// ─────────────────────────────────────────────
// Test 2: IAM user tags are applied correctly
// ─────────────────────────────────────────────

func TestIAMUserTags(t *testing.T) {
	t.Parallel()

	opts := terraformOptions(t, map[string]interface{}{
		"users": map[string]interface{}{
			"test-tag-user": map[string]interface{}{
				"console_access":  false,
				"pgp_key":         nil,
				"password_length": 20,
			},
		},
	})

	defer terraform.Destroy(t, opts)
	terraform.InitAndApply(t, opts)

	iamClient := newIAMClient(t, "us-east-1")

	output, err := iamClient.ListUserTags(&iam.ListUserTagsInput{
		UserName: aws.String("test-tag-user"),
	})
	require.NoError(t, err)

	tags := make(map[string]string)
	for _, tag := range output.Tags {
		tags[aws.StringValue(tag.Key)] = aws.StringValue(tag.Value)
	}

	assert.Equal(t, "test-project", tags["Project"])
	assert.Equal(t, "test", tags["Environment"])
	assert.Equal(t, "Terraform", tags["managed_by"])
	assert.Equal(t, "test-project-test-user", tags["Name"])
}

// ─────────────────────────────────────────────
// Test 3: Console access user has login profile
// ─────────────────────────────────────────────

func TestConsoleAccessUserHasLoginProfile(t *testing.T) {
	t.Parallel()

	opts := terraformOptions(t, map[string]interface{}{
		"users": map[string]interface{}{
			"test-console-user": map[string]interface{}{
				"console_access":  true,
				"pgp_key":         "keybase:your_keybase_username",
				"password_length": 20,
			},
		},
	})

	defer terraform.Destroy(t, opts)
	terraform.InitAndApply(t, opts)

	iamClient := newIAMClient(t, "us-east-1")

	output, err := iamClient.GetLoginProfile(&iam.GetLoginProfileInput{
		UserName: aws.String("test-console-user"),
	})
	require.NoError(t, err)
	assert.Equal(t, "test-console-user", aws.StringValue(output.LoginProfile.UserName))
	assert.True(t, aws.BoolValue(output.LoginProfile.PasswordResetRequired))
}

// ─────────────────────────────────────────────
// Test 4: Non-console user has no login profile
// ─────────────────────────────────────────────

func TestNonConsoleUserHasNoLoginProfile(t *testing.T) {
	t.Parallel()

	opts := terraformOptions(t, map[string]interface{}{
		"users": map[string]interface{}{
			"test-svc-user": map[string]interface{}{
				"console_access":  false,
				"pgp_key":         nil,
				"password_length": 20,
			},
		},
	})

	defer terraform.Destroy(t, opts)
	terraform.InitAndApply(t, opts)

	iamClient := newIAMClient(t, "us-east-1")

	_, err := iamClient.GetLoginProfile(&iam.GetLoginProfileInput{
		UserName: aws.String("test-svc-user"),
	})

	// Should return NoSuchEntity error — login profile must not exist
	require.Error(t, err)
	assert.Contains(t, err.Error(), "NoSuchEntity")
}

// ─────────────────────────────────────────────
// Test 5: Terraform outputs are correct
// ─────────────────────────────────────────────

func TestIAMUserOutputs(t *testing.T) {
	t.Parallel()

	opts := terraformOptions(t, map[string]interface{}{
		"users": map[string]interface{}{
			"test-output-user": map[string]interface{}{
				"console_access":  false,
				"pgp_key":         nil,
				"password_length": 20,
			},
		},
	})

	defer terraform.Destroy(t, opts)
	terraform.InitAndApply(t, opts)

	// Validate user_arns output
	userArns := terraform.OutputMap(t, opts, "user_arns")
	assert.Contains(t, userArns["test-output-user"], "arn:aws:iam::")
	assert.Contains(t, userArns["test-output-user"], "test-output-user")

	// Validate user_names output
	userNames := terraform.OutputMap(t, opts, "user_names")
	assert.Equal(t, "test-output-user", userNames["test-output-user"])
}

// ─────────────────────────────────────────────
// Test 6: force_destroy allows clean deletion
// ─────────────────────────────────────────────

func TestIAMUserForceDestroy(t *testing.T) {
	t.Parallel()

	opts := terraformOptions(t, map[string]interface{}{
		"users": map[string]interface{}{
			"test-destroy-user": map[string]interface{}{
				"console_access":  true,
				"pgp_key":         "keybase:your_keybase_username",
				"password_length": 20,
			},
		},
	})

	terraform.InitAndApply(t, opts)

	// Destroy should succeed without 409 DeleteConflict error
	_, err := terraform.DestroyE(t, opts)
	assert.NoError(t, err, "Destroy should succeed without DeleteConflict error")

	// Confirm user no longer exists
	iamClient := newIAMClient(t, "us-east-1")
	_, err = iamClient.GetUser(&iam.GetUserInput{
		UserName: aws.String("test-destroy-user"),
	})
	require.Error(t, err)
	assert.Contains(t, err.Error(), "NoSuchEntity")
}

// ─────────────────────────────────────────────
// Test 7: Full end-to-end test
// ─────────────────────────────────────────────

func TestIAMUserEndToEnd(t *testing.T) {
	opts := terraformOptions(t, map[string]interface{}{
		"users": map[string]interface{}{
			"test-e2e-alice": map[string]interface{}{
				"console_access":  true,
				"pgp_key":         "keybase:your_keybase_username",
				"password_length": 20,
			},
			"test-e2e-bob": map[string]interface{}{
				"console_access":  false,
				"pgp_key":         nil,
				"password_length": 20,
			},
		},
	})

	defer terraform.Destroy(t, opts)
	terraform.InitAndApply(t, opts)

	iamClient := newIAMClient(t, "us-east-1")

	// Alice — console user
	t.Run("alice_exists", func(t *testing.T) {
		out, err := iamClient.GetUser(&iam.GetUserInput{UserName: aws.String("test-e2e-alice")})
		require.NoError(t, err)
		assert.Equal(t, "test-e2e-alice", aws.StringValue(out.User.UserName))
	})

	t.Run("alice_has_login_profile", func(t *testing.T) {
		out, err := iamClient.GetLoginProfile(&iam.GetLoginProfileInput{UserName: aws.String("test-e2e-alice")})
		require.NoError(t, err)
		assert.True(t, aws.BoolValue(out.LoginProfile.PasswordResetRequired))
	})

	t.Run("alice_has_correct_tags", func(t *testing.T) {
		out, err := iamClient.ListUserTags(&iam.ListUserTagsInput{UserName: aws.String("test-e2e-alice")})
		require.NoError(t, err)
		tags := make(map[string]string)
		for _, tag := range out.Tags {
			tags[aws.StringValue(tag.Key)] = aws.StringValue(tag.Value)
		}
		assert.Equal(t, "test-project", tags["Project"])
		assert.Equal(t, "test", tags["Environment"])
	})

	// Bob — service user
	t.Run("bob_exists", func(t *testing.T) {
		out, err := iamClient.GetUser(&iam.GetUserInput{UserName: aws.String("test-e2e-bob")})
		require.NoError(t, err)
		assert.Equal(t, "test-e2e-bob", aws.StringValue(out.User.UserName))
	})

	t.Run("bob_has_no_login_profile", func(t *testing.T) {
		_, err := iamClient.GetLoginProfile(&iam.GetLoginProfileInput{UserName: aws.String("test-e2e-bob")})
		require.Error(t, err)
		assert.Contains(t, err.Error(), "NoSuchEntity")
	})
}