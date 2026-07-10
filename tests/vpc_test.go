package test

import (
	"testing"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestVPCModule(t *testing.T) {

	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../", // root where your main.tf exists

		VarFiles: []string{
			"environment/learning/terraform.tfvars",
		},
	}

	// Cleanup after test
	defer terraform.Destroy(t, terraformOptions)

	// Init + Apply
	terraform.InitAndApply(t, terraformOptions)

	// ---- VALIDATIONS ----

	// 1. VPC ID should exist
	vpcID := terraform.Output(t, terraformOptions, "vpc_id")
	assert.NotEmpty(t, vpcID)

	// 2. CIDR validation
	vpcCIDR := terraform.Output(t, terraformOptions, "vpc_cidr")
	assert.Equal(t, "10.0.0.0/16", vpcCIDR)

	// 3. Public Subnets count
	publicSubnetIDs := terraform.OutputList(t, terraformOptions, "public_subnet_ids")
	assert.Greater(t, len(publicSubnetIDs), 0)

	// 4. Private Subnets count
	privateSubnetIDs := terraform.OutputList(t, terraformOptions, "private_subnet_ids")
	assert.Greater(t, len(privateSubnetIDs), 0)

	// 5. Tags validation
	tags := terraform.OutputMap(t, terraformOptions, "tags")
	assert.Equal(t, "DevOps", tags["Owner"])
}
