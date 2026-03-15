import { prisma } from "../config/database";

interface CreateMessageInput {
  sender_uid: string;
  receiver_uid: string;
  message: string;
  timestamp?: Date;
}

interface ConversationQuery {
  userA: string;
  userB: string;
}

export class MessageRepository {
  async create(input: CreateMessageInput) {
    return prisma.message.create({
      data: {
        sender_uid: input.sender_uid,
        receiver_uid: input.receiver_uid,
        message: input.message,
        timestamp: input.timestamp ?? new Date(),
      },
      select: {
        id: true,
        sender_uid: true,
        receiver_uid: true,
        message: true,
        timestamp: true,
      },
    });
  }

  async findConversation(query: ConversationQuery) {
    return prisma.message.findMany({
      where: {
        OR: [
          {
            sender_uid: query.userA,
            receiver_uid: query.userB,
          },
          {
            sender_uid: query.userB,
            receiver_uid: query.userA,
          },
        ],
      },
      orderBy: { timestamp: "asc" },
      select: {
        id: true,
        sender_uid: true,
        receiver_uid: true,
        message: true,
        timestamp: true,
      },
    });
  }
}
