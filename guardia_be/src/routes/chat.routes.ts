import { Router } from "express";
import { ChatController } from "../controllers/chat.controller";
import { authMiddleware } from "../middlewares/auth.middleware";
import { validate } from "../middlewares/validate.middleware";
import { chatHistorySchema } from "../validators/chat.validator";

const router = Router();
const controller = new ChatController();

router.use(authMiddleware);

router.get("/history", validate(chatHistorySchema), controller.history);

export { router as chatRoutes };
