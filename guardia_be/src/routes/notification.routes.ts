import { Router } from "express";
import { NotificationController } from "../controllers/notification.controller";
import { authMiddleware } from "../middlewares/auth.middleware";
import { validate } from "../middlewares/validate.middleware";
import {
  listNotificationsSchema,
  notificationIdSchema,
} from "../validators/notification.validator";

const router = Router();
const controller = new NotificationController();

router.use(authMiddleware);

router.get("/", validate(listNotificationsSchema), controller.list);
router.get("/unread-count", controller.getUnreadCount);
router.post("/mark-all-read", controller.markAllAsRead);
router.post("/:id/read", validate(notificationIdSchema), controller.markAsRead);

export { router as notificationRoutes };
