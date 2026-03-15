import { Router } from "express";
import { authRoutes } from "./auth.routes";
import { riskAreaRoutes } from "./risk-area.routes";
import { routeRoutes } from "./route.routes";
import { analysisRoutes } from "./analysis.routes";
import { profileRoutes } from "./profile.routes";
import { trustedContactRoutes } from "./trusted-contact.routes";
import { panicRoutes } from "./panic.routes";
import { notificationRoutes } from "./notification.routes";
import { reportRoutes } from "./report.routes";
import { chatRoutes } from "./chat.routes";

const router = Router();

router.use("/auth", authRoutes);
router.use("/risk-areas", riskAreaRoutes);
router.use("/route", routeRoutes);
router.use("/analysis", analysisRoutes);
router.use("/profile", profileRoutes);
router.use("/trusted-contacts", trustedContactRoutes);
router.use("/panic", panicRoutes);
router.use("/notifications", notificationRoutes);
router.use("/reports", reportRoutes);
router.use("/chat", chatRoutes);

export { router as apiRouter };
