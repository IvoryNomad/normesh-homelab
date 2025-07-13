# AWS S3 Backend Setup for OpenTofu
# Configuration variables
BUCKET_NAME ?= normesh-homelab-tofu-state
REGION ?= us-east-1
IAM_USER ?= opentofu-state-user
IAM_POLICY_NAME ?= OpenTofuStatePolicy
DYNAMODB_TABLE ?= tofu-state-lock

# Get AWS account ID
ACCOUNT_ID := $(shell aws sts get-caller-identity --query Account --output text 2>/dev/null)

.PHONY: help setup create-bucket configure-bucket create-iam create-dynamodb test status clean

help: ## Show this help message
	@echo "AWS S3 Backend Setup for OpenTofu"
	@echo ""
	@echo "Configuration:"
	@echo "  BUCKET_NAME: $(BUCKET_NAME)"
	@echo "  REGION: $(REGION)"
	@echo "  IAM_USER: $(IAM_USER)"
	@echo "  IAM_POLICY_NAME: $(IAM_POLICY_NAME)"
	@echo "  ACCOUNT_ID: $(ACCOUNT_ID)"
	@echo ""
	@echo "Usage:"
	@echo "  make setup           - Complete setup (bucket + IAM + DynamoDB)"
	@echo "  make create-bucket   - Create and configure S3 bucket"
	@echo "  make create-iam      - Create IAM user and policy"
	@echo "  make create-dynamodb - Create DynamoDB table for state locking"
	@echo "  make test           - Test the setup"
	@echo "  make status         - Show current status of all resources"
	@echo "  make clean          - Remove all created resources"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-16s %s\n", $$1, $$2}'

setup: create-bucket configure-bucket create-iam create-dynamodb ## Complete setup process
	@echo "✅ S3 backend setup complete!"
	@echo ""
	@echo "Add this to your OpenTofu configuration:"
	@echo ""
	@echo "terraform {"
	@echo "  backend \"s3\" {"
	@echo "    bucket         = \"$(BUCKET_NAME)\""
	@echo "    key            = \"path/to/your/terraform.tfstate\""
	@echo "    region         = \"$(REGION)\""
	@echo "    dynamodb_table = \"$(DYNAMODB_TABLE)\""
	@echo "    encrypt        = true"
	@echo "  }"
	@echo "}"

create-bucket: ## Create S3 bucket
	@echo "🪣 Checking S3 bucket: $(BUCKET_NAME)"
	@if aws s3 ls s3://$(BUCKET_NAME) >/dev/null 2>&1; then \
		echo "✅ Bucket $(BUCKET_NAME) already exists"; \
	else \
		echo "📦 Creating S3 bucket: $(BUCKET_NAME)"; \
		aws s3 mb s3://$(BUCKET_NAME) --region $(REGION); \
		echo "✅ Bucket created"; \
	fi

configure-bucket: create-bucket ## Configure bucket security settings
	@echo "🔒 Configuring bucket security..."
	
	# Check and enable versioning if needed
	@if aws s3api get-bucket-versioning --bucket $(BUCKET_NAME) --query 'Status' --output text 2>/dev/null | grep -q "Enabled"; then \
		echo "✅ Versioning already enabled"; \
	else \
		echo "📝 Enabling versioning..."; \
		aws s3api put-bucket-versioning \
			--bucket $(BUCKET_NAME) \
			--versioning-configuration Status=Enabled; \
	fi
	
	# Check and enable encryption if needed
	@if aws s3api get-bucket-encryption --bucket $(BUCKET_NAME) >/dev/null 2>&1; then \
		echo "✅ Encryption already configured"; \
	else \
		echo "🔐 Enabling encryption..."; \
		aws s3api put-bucket-encryption \
			--bucket $(BUCKET_NAME) \
			--server-side-encryption-configuration file://s3-encryption.json; \
	fi
	
	# Check and configure public access block if needed
	@if aws s3api get-public-access-block --bucket $(BUCKET_NAME) --query 'PublicAccessBlockConfiguration.BlockPublicAcls' --output text 2>/dev/null | grep -q "True"; then \
		echo "✅ Public access already blocked"; \
	else \
		echo "🚫 Blocking public access..."; \
		aws s3api put-public-access-block \
			--bucket $(BUCKET_NAME) \
			--public-access-block-configuration \
			BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true; \
	fi
	
	@echo "✅ Bucket security configured"

create-iam: iam-policy.json ## Create IAM user and policy
	@echo "👤 Checking IAM policy and user..."
	
	# Substitute bucket name in policy template
	@sed 's/BUCKET_NAME_PLACEHOLDER/$(BUCKET_NAME)/g' iam-policy.json > iam-policy-final.json
	
	# Check and create policy if needed
	@if aws iam get-policy --policy-arn arn:aws:iam::$(ACCOUNT_ID):policy/$(IAM_POLICY_NAME) >/dev/null 2>&1; then \
		echo "✅ IAM policy $(IAM_POLICY_NAME) already exists"; \
		echo "🔄 Updating policy with current configuration..."; \
		aws iam create-policy-version \
			--policy-arn arn:aws:iam::$(ACCOUNT_ID):policy/$(IAM_POLICY_NAME) \
			--policy-document file://iam-policy-final.json \
			--set-as-default >/dev/null 2>&1 || echo "⚠️  Policy update failed (may already be current)"; \
	else \
		echo "📋 Creating IAM policy..."; \
		aws iam create-policy \
			--policy-name $(IAM_POLICY_NAME) \
			--policy-document file://iam-policy-final.json \
			--description "Policy for OpenTofu state management"; \
	fi
	
	# Check and create user if needed
	@if aws iam get-user --user-name $(IAM_USER) >/dev/null 2>&1; then \
		echo "✅ IAM user $(IAM_USER) already exists"; \
	else \
		echo "👤 Creating IAM user..."; \
		aws iam create-user --user-name $(IAM_USER); \
	fi
	
	# Check and attach policy if needed
	@if aws iam list-attached-user-policies --user-name $(IAM_USER) --query 'AttachedPolicies[?PolicyName==`$(IAM_POLICY_NAME)`]' --output text | grep -q "$(IAM_POLICY_NAME)"; then \
		echo "✅ Policy already attached to user"; \
	else \
		echo "🔗 Attaching policy to user..."; \
		aws iam attach-user-policy \
			--user-name $(IAM_USER) \
			--policy-arn arn:aws:iam::$(ACCOUNT_ID):policy/$(IAM_POLICY_NAME); \
	fi
	
	# Check if user has access keys
	@if aws iam list-access-keys --user-name $(IAM_USER) --query 'AccessKeyMetadata' --output text | grep -q "AKIA"; then \
		echo "✅ Access key already exists for user"; \
		echo "🔑 Existing access keys:"; \
		aws iam list-access-keys --user-name $(IAM_USER) --output table; \
	else \
		echo "🔑 Creating access key (save these credentials!):"; \
		aws iam create-access-key --user-name $(IAM_USER) --output table; \
	fi
	
	# Clean up temp file
	@rm -f iam-policy-final.json
	
	@echo "✅ IAM user and policy configured"

create-dynamodb: ## Create DynamoDB table for state locking
	@echo "🗃️  Checking DynamoDB table for state locking..."
	@if aws dynamodb describe-table --table-name $(DYNAMODB_TABLE) --region $(REGION) >/dev/null 2>&1; then \
		echo "✅ DynamoDB table $(DYNAMODB_TABLE) already exists"; \
		if aws dynamodb describe-table --table-name $(DYNAMODB_TABLE) --region $(REGION) --query 'Table.TableStatus' --output text | grep -q "ACTIVE"; then \
			echo "✅ Table is active and ready"; \
		else \
			echo "⏳ Table exists but not active, waiting..."; \
			aws dynamodb wait table-exists --table-name $(DYNAMODB_TABLE) --region $(REGION); \
			echo "✅ Table is now active"; \
		fi \
	else \
		echo "📊 Creating DynamoDB table..."; \
		aws dynamodb create-table \
			--table-name $(DYNAMODB_TABLE) \
			--attribute-definitions AttributeName=LockID,AttributeType=S \
			--key-schema AttributeName=LockID,KeyType=HASH \
			--billing-mode PAY_PER_REQUEST \
			--region $(REGION); \
		echo "⏳ Waiting for table to be active..."; \
		aws dynamodb wait table-exists --table-name $(DYNAMODB_TABLE) --region $(REGION); \
		echo "✅ DynamoDB table created and active"; \
	fi

test: ## Test the setup
	@echo "🧪 Testing S3 backend setup..."
	
	# Test bucket access
	@if aws s3 ls s3://$(BUCKET_NAME) >/dev/null 2>&1; then echo "✅ S3 bucket accessible"; else echo "❌ S3 bucket not accessible"; fi
	
	# Test DynamoDB table
	@if aws dynamodb describe-table --table-name $(DYNAMODB_TABLE) --region $(REGION) >/dev/null 2>&1; then echo "✅ DynamoDB table accessible"; else echo "❌ DynamoDB table not accessible"; fi
	
	# Test IAM user
	@if aws iam get-user --user-name $(IAM_USER) >/dev/null 2>&1; then echo "✅ IAM user exists"; else echo "❌ IAM user not found"; fi

status: ## Show current status of all resources
	@echo "📊 Current AWS S3 Backend Status"
	@echo "================================"
	@echo ""
	
	# S3 Bucket Status
	@echo "🪣 S3 Bucket: $(BUCKET_NAME)"
	@if aws s3 ls s3://$(BUCKET_NAME) >/dev/null 2>&1; then \
		echo "  Status: ✅ Exists"; \
		echo "  Region: $(aws s3api get-bucket-location --bucket $(BUCKET_NAME) --query 'LocationConstraint' --output text 2>/dev/null || echo 'us-east-1')"; \
		if aws s3api get-bucket-versioning --bucket $(BUCKET_NAME) --query 'Status' --output text 2>/dev/null | grep -q "Enabled"; then \
			echo "  Versioning: ✅ Enabled"; \
		else \
			echo "  Versioning: ❌ Disabled"; \
		fi; \
		if aws s3api get-bucket-encryption --bucket $(BUCKET_NAME) >/dev/null 2>&1; then \
			echo "  Encryption: ✅ Enabled"; \
		else \
			echo "  Encryption: ❌ Disabled"; \
		fi; \
		if aws s3api get-public-access-block --bucket $(BUCKET_NAME) --query 'PublicAccessBlockConfiguration.BlockPublicAcls' --output text 2>/dev/null | grep -q "True"; then \
			echo "  Public Access: ✅ Blocked"; \
		else \
			echo "  Public Access: ⚠️  Not fully blocked"; \
		fi; \
	else \
		echo "  Status: ❌ Does not exist"; \
	fi
	@echo ""
	
	# DynamoDB Status
	@echo "🗃️  DynamoDB Table: $(DYNAMODB_TABLE)"
	@if aws dynamodb describe-table --table-name $(DYNAMODB_TABLE) --region $(REGION) >/dev/null 2>&1; then \
		STATUS=$(aws dynamodb describe-table --table-name $(DYNAMODB_TABLE) --region $(REGION) --query 'Table.TableStatus' --output text); \
		echo "  Status: ✅ Exists ($STATUS)"; \
		echo "  Region: $(REGION)"; \
	else \
		echo "  Status: ❌ Does not exist"; \
	fi
	@echo ""
	
	# IAM Status  
	@echo "👤 IAM User: $(IAM_USER)"
	@if aws iam get-user --user-name $(IAM_USER) >/dev/null 2>&1; then \
		echo "  Status: ✅ Exists"; \
		KEYS_COUNT=$(aws iam list-access-keys --user-name $(IAM_USER) --query 'length(AccessKeyMetadata)' --output text); \
		echo "  Access Keys: $KEYS_COUNT"; \
		if aws iam list-attached-user-policies --user-name $(IAM_USER) --query 'AttachedPolicies[?PolicyName==`$(IAM_POLICY_NAME)`]' --output text | grep -q "$(IAM_POLICY_NAME)"; then \
			echo "  Policy Attached: ✅ $(IAM_POLICY_NAME)"; \
		else \
			echo "  Policy Attached: ❌ $(IAM_POLICY_NAME) not attached"; \
		fi; \
	else \
		echo "  Status: ❌ Does not exist"; \
	fi
	@echo ""
	
	# IAM Policy Status
	@echo "📋 IAM Policy: $(IAM_POLICY_NAME)"
	@if aws iam get-policy --policy-arn arn:aws:iam::$(ACCOUNT_ID):policy/$(IAM_POLICY_NAME) >/dev/null 2>&1; then \
		echo "  Status: ✅ Exists"; \
		echo "  ARN: arn:aws:iam::$(ACCOUNT_ID):policy/$(IAM_POLICY_NAME)"; \
	else \
		echo "  Status: ❌ Does not exist"; \
	fi

clean: ## Remove all created resources (DESTRUCTIVE!)
	@echo "⚠️  This will delete all created AWS resources!"
	@read -p "Are you sure? (y/N): " confirm && [ "$confirm" = "y" ] || exit 1
	
	@echo "🧹 Cleaning up resources..."
	
	# Delete DynamoDB table
	@if aws dynamodb describe-table --table-name $(DYNAMODB_TABLE) --region $(REGION) >/dev/null 2>&1; then \
		echo "🗑️  Deleting DynamoDB table..."; \
		aws dynamodb delete-table --table-name $(DYNAMODB_TABLE) --region $(REGION); \
	else \
		echo "✅ DynamoDB table $(DYNAMODB_TABLE) doesn't exist"; \
	fi
	
	# Detach policy from user
	@if aws iam get-user --user-name $(IAM_USER) >/dev/null 2>&1; then \
		if aws iam list-attached-user-policies --user-name $(IAM_USER) --query 'AttachedPolicies[?PolicyName==`$(IAM_POLICY_NAME)`]' --output text | grep -q "$(IAM_POLICY_NAME)"; then \
			echo "🔗 Detaching policy from user..."; \
			aws iam detach-user-policy \
				--user-name $(IAM_USER) \
				--policy-arn arn:aws:iam::$(ACCOUNT_ID):policy/$(IAM_POLICY_NAME); \
		fi; \
		echo "🔑 Deleting access keys..."; \
		aws iam list-access-keys --user-name $(IAM_USER) --query 'AccessKeyMetadata[].AccessKeyId' --output text | \
			xargs -I {} aws iam delete-access-key --user-name $(IAM_USER) --access-key-id {} 2>/dev/null || true; \
		echo "👤 Deleting IAM user..."; \
		aws iam delete-user --user-name $(IAM_USER); \
	else \
		echo "✅ IAM user $(IAM_USER) doesn't exist"; \
	fi
	
	# Delete policy
	@if aws iam get-policy --policy-arn arn:aws:iam::$(ACCOUNT_ID):policy/$(IAM_POLICY_NAME) >/dev/null 2>&1; then \
		echo "📋 Deleting IAM policy..."; \
		aws iam delete-policy --policy-arn arn:aws:iam::$(ACCOUNT_ID):policy/$(IAM_POLICY_NAME); \
	else \
		echo "✅ IAM policy $(IAM_POLICY_NAME) doesn't exist"; \
	fi
	
	# Delete S3 bucket (must be empty first)
	@if aws s3 ls s3://$(BUCKET_NAME) >/dev/null 2>&1; then \
		echo "🗑️  Emptying and deleting S3 bucket..."; \
		aws s3 rm s3://$(BUCKET_NAME) --recursive 2>/dev/null || true; \
		aws s3 rb s3://$(BUCKET_NAME); \
	else \
		echo "✅ S3 bucket $(BUCKET_NAME) doesn't exist"; \
	fi
	
	@echo "✅ Cleanup complete"

# Ensure required files exist
iam-policy.json:
	@echo "❌ iam-policy.json not found. Run 'make help' for setup instructions."
	@exit 1
