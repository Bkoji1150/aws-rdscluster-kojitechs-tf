{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Effect": "Allow",
			"Principal": {
				"AWS": "arn:aws:iam::674293488770:root"
			},
			"Action": [
				"sts:AssumeRole"
			],
			"Condition": {}
		},
		{
			"Effect": "Allow",
			"Principal": {
				"AWS": "arn:aws:iam::735972722491:root"
			},
			"Action": [
				"sts:AssumeRole"
			],
			"Condition": {}
		},
		{
			"Effect": "Allow",
			"Principal": {
				"AWS": "arn:aws:iam::181437319056:root"
			},
			"Action": [
				"sts:AssumeRole"
			],
			"Condition": {}
		}
	]
}    

## ROLE NAME: cross-account-terraform-role