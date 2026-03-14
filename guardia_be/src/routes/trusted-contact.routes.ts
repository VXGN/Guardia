import { Router } from "express";
import { TrustedContactController } from "../controllers/trusted-contact.controller";
import { authMiddleware } from "../middlewares/auth.middleware";
import { validate } from "../middlewares/validate.middleware";
import {
  createTrustedContactSchema,
  updateTrustedContactSchema,
  trustedContactIdSchema,
} from "../validators/trusted-contact.validator";

const router = Router();
const controller = new TrustedContactController();

router.use(authMiddleware);

router.get("/", controller.list);
router.post("/", validate(createTrustedContactSchema), controller.create);
router.put("/:id", validate(updateTrustedContactSchema), controller.update);
router.delete("/:id", validate(trustedContactIdSchema), controller.delete);

export { router as trustedContactRoutes };
