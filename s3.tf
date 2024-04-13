resource "aws_sqs_queue" "queue" {
    name = "${var.app}-s3-event-notification-queue"
    policy = <<POLICY
    {
    "Version": "2012-10-17",
    "Statement": [
        {
        "Effect": "Allow",
        "Principal": "*",
        "Action": "sqs:SendMessage",
        "Resource": "arn:aws:sqs:*:*:${var.app}-s3-event-notification-queue",
        "Condition": {
            "ArnEquals": { "aws:SourceArn": "${aws_s3_bucket.bucket.arn}" }
        }
        }
    ]
    }
POLICY
}

resource "aws_s3_bucket" "bucket" {
    bucket = "${var.app}-s3-bucket"
    force_destroy = true
}

resource "aws_s3_bucket_notification" "bucket_notification" {
    bucket = aws_s3_bucket.bucket.id
    queue {
        queue_arn     = aws_sqs_queue.queue.arn
        events        = ["s3:ObjectCreated:*"]
    }
}
# Event source from SQS
resource "aws_lambda_event_source_mapping" "event_source_mapping" {
    event_source_arn = aws_sqs_queue.queue.arn
    enabled          = true
    function_name    = aws_lambda_function.sqs_processor.arn
    batch_size       = 1
}