CREATE TABLE "messages" (
  "id" CHAR(36) NOT NULL,
  "sender_uid" CHAR(36) NOT NULL,
  "receiver_uid" CHAR(36) NOT NULL,
  "message" TEXT NOT NULL,
  "timestamp" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT "messages_pkey" PRIMARY KEY ("id")
);

CREATE INDEX "messages_sender_uid_idx" ON "messages"("sender_uid");
CREATE INDEX "messages_receiver_uid_idx" ON "messages"("receiver_uid");
CREATE INDEX "messages_timestamp_idx" ON "messages"("timestamp");
CREATE INDEX "messages_conversation_idx" ON "messages"("sender_uid", "receiver_uid", "timestamp");

ALTER TABLE "messages"
  ADD CONSTRAINT "messages_sender_uid_fkey"
  FOREIGN KEY ("sender_uid") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "messages"
  ADD CONSTRAINT "messages_receiver_uid_fkey"
  FOREIGN KEY ("receiver_uid") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
