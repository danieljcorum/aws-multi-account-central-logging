data "aws_iam_policy_document" "destination_policy" {
  statement {
    effect = "Allow"

    principals {
      type = "AWS"

      identifiers = var.bu_acct_num
    }

    actions = [
      "*",
    ]

    resources = ["*"]
  }
}

resource "aws_cloudwatch_log_destination_policy" "destination_policy" {
  count = length(var.aws_cloudwatch_log_destination_name)
  destination_name = element(var.log_destination_name_list, count.index)
  access_policy    = data.aws_iam_policy_document.destination_policy.json
}
