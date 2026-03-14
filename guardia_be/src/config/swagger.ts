import { Express } from "express";

const swaggerSpec = {
  openapi: "3.0.0",
  info: {
    title: "Guardia API",
    version: "1.0.0",
    description: "Backend service for a safety map application that displays risk-prone areas and calculates safer routes.",
  },
  servers: [{ url: "/" }],
  components: {
    securitySchemes: {
      bearerAuth: {
        type: "http",
        scheme: "bearer",
        bearerFormat: "JWT",
      },
    },
  },
  security: [{ bearerAuth: [] }],
  paths: {
    "/health": {
      get: {
        tags: ["Health"],
        summary: "Health check",
        responses: {
          "200": {
            description: "OK",
            content: {
              "application/json": {
                schema: {
                  type: "object",
                  properties: {
                    success: { type: "boolean" },
                    message: { type: "string" },
                    data: { type: "object" },
                  },
                },
              },
            },
          },
        },
      },
    },
    "/api/auth/verify": {
      post: {
        tags: ["Auth"],
        summary: "Verify Firebase token",
        requestBody: {
          required: true,
          content: {
            "application/json": {
              schema: {
                type: "object",
                properties: {
                  token: { type: "string" },
                },
                required: ["token"],
              },
            },
          },
        },
        responses: {
          "200": { description: "Token verified successfully" },
          "400": { description: "Validation error" },
          "401": { description: "Invalid or expired Firebase token" },
        },
      },
    },
    "/api/profile": {
      get: {
        tags: ["Profile"],
        summary: "Get user profile",
        responses: {
          "200": { description: "Profile retrieved successfully" },
          "401": { description: "Unauthorized" },
          "404": { description: "User not found" },
        },
      },
      put: {
        tags: ["Profile"],
        summary: "Update user profile",
        requestBody: {
          required: true,
          content: {
            "application/json": {
              schema: {
                type: "object",
                properties: {
                  full_name: { type: "string", maxLength: 100 },
                  phone_number: { type: "string" },
                  is_anonymous_mode: { type: "boolean" },
                  fcm_token: { type: "string" },
                },
              },
            },
          },
        },
        responses: {
          "200": { description: "Profile updated successfully" },
          "400": { description: "Validation error" },
          "401": { description: "Unauthorized" },
        },
      },
    },
    "/api/trusted-contacts": {
      get: {
        tags: ["Trusted Contacts"],
        summary: "List trusted contacts",
        responses: {
          "200": { description: "Trusted contacts retrieved successfully" },
          "401": { description: "Unauthorized" },
        },
      },
      post: {
        tags: ["Trusted Contacts"],
        summary: "Create trusted contact",
        requestBody: {
          required: true,
          content: {
            "application/json": {
              schema: {
                type: "object",
                properties: {
                  contact_name: { type: "string", maxLength: 100 },
                  contact_phone: { type: "string" },
                  contact_email: { type: "string" },
                },
                required: ["contact_name", "contact_phone"],
              },
            },
          },
        },
        responses: {
          "201": { description: "Trusted contact created successfully" },
          "400": { description: "Validation error" },
          "401": { description: "Unauthorized" },
        },
      },
    },
    "/api/trusted-contacts/{id}": {
      put: {
        tags: ["Trusted Contacts"],
        summary: "Update trusted contact",
        parameters: [{ name: "id", in: "path", required: true, schema: { type: "string", format: "uuid" } }],
        requestBody: {
          required: true,
          content: {
            "application/json": {
              schema: {
                type: "object",
                properties: {
                  contact_name: { type: "string" },
                  contact_phone: { type: "string" },
                  contact_email: { type: "string" },
                  is_active: { type: "boolean" },
                },
              },
            },
          },
        },
        responses: {
          "200": { description: "Trusted contact updated successfully" },
          "400": { description: "Validation error" },
          "401": { description: "Unauthorized" },
          "404": { description: "Contact not found" },
        },
      },
      delete: {
        tags: ["Trusted Contacts"],
        summary: "Delete trusted contact",
        parameters: [{ name: "id", in: "path", required: true, schema: { type: "string", format: "uuid" } }],
        responses: {
          "204": { description: "Contact deleted successfully" },
          "401": { description: "Unauthorized" },
          "404": { description: "Contact not found" },
        },
      },
    },
    "/api/panic/trigger": {
      post: {
        tags: ["Panic Alert"],
        summary: "Trigger panic alert",
        description: "Sends emergency notifications to all active trusted contacts with user location",
        requestBody: {
          required: true,
          content: {
            "application/json": {
              schema: {
                type: "object",
                properties: {
                  latitude: { type: "number", minimum: -90, maximum: 90 },
                  longitude: { type: "number", minimum: -180, maximum: 180 },
                  message: { type: "string", maxLength: 500 },
                },
                required: ["latitude", "longitude"],
              },
            },
          },
        },
        responses: {
          "200": { description: "Panic alert triggered successfully" },
          "400": { description: "Validation error" },
          "401": { description: "Unauthorized" },
        },
      },
    },
    "/api/notifications": {
      get: {
        tags: ["Notifications"],
        summary: "List notifications",
        parameters: [
          { name: "limit", in: "query", schema: { type: "integer", default: 20 } },
          { name: "offset", in: "query", schema: { type: "integer", default: 0 } },
          { name: "unread_only", in: "query", schema: { type: "boolean", default: false } },
        ],
        responses: {
          "200": { description: "Notifications retrieved successfully" },
          "401": { description: "Unauthorized" },
        },
      },
    },
    "/api/notifications/unread-count": {
      get: {
        tags: ["Notifications"],
        summary: "Get unread notification count",
        responses: {
          "200": { description: "Unread count retrieved successfully" },
          "401": { description: "Unauthorized" },
        },
      },
    },
    "/api/notifications/mark-all-read": {
      post: {
        tags: ["Notifications"],
        summary: "Mark all notifications as read",
        responses: {
          "200": { description: "All notifications marked as read" },
          "401": { description: "Unauthorized" },
        },
      },
    },
    "/api/notifications/{id}/read": {
      post: {
        tags: ["Notifications"],
        summary: "Mark notification as read",
        parameters: [{ name: "id", in: "path", required: true, schema: { type: "string", format: "uuid" } }],
        responses: {
          "200": { description: "Notification marked as read" },
          "401": { description: "Unauthorized" },
          "404": { description: "Notification not found" },
        },
      },
    },
    "/api/reports": {
      get: {
        tags: ["Reports"],
        summary: "List incident reports",
        parameters: [
          { name: "limit", in: "query", schema: { type: "integer", default: 20 } },
          { name: "offset", in: "query", schema: { type: "integer", default: 0 } },
          { name: "status", in: "query", schema: { type: "string", enum: ["received", "verified", "in_progress", "resolved", "rejected"] } },
          { name: "incident_type", in: "query", schema: { type: "string", enum: ["verbal_harassment", "physical_harassment", "stalking", "theft", "intimidation", "other"] } },
        ],
        responses: {
          "200": { description: "Reports retrieved successfully" },
          "401": { description: "Unauthorized" },
        },
      },
      post: {
        tags: ["Reports"],
        summary: "Create incident report",
        requestBody: {
          required: true,
          content: {
            "application/json": {
              schema: {
                type: "object",
                properties: {
                  incident_type: { type: "string", enum: ["verbal_harassment", "physical_harassment", "stalking", "theft", "intimidation", "other"] },
                  description: { type: "string", minLength: 10, maxLength: 2000 },
                  incident_at: { type: "string", format: "date-time" },
                  latitude: { type: "number", minimum: -90, maximum: 90 },
                  longitude: { type: "number", minimum: -180, maximum: 180 },
                  location_label: { type: "string", maxLength: 255 },
                  is_anonymous: { type: "boolean", default: false },
                },
                required: ["incident_type", "description", "incident_at", "latitude", "longitude"],
              },
            },
          },
        },
        responses: {
          "201": { description: "Report created successfully" },
          "400": { description: "Validation error" },
          "401": { description: "Unauthorized" },
        },
      },
    },
    "/api/reports/my": {
      get: {
        tags: ["Reports"],
        summary: "Get my reports",
        description: "List reports created by the authenticated user",
        parameters: [
          { name: "limit", in: "query", schema: { type: "integer", default: 20 } },
          { name: "offset", in: "query", schema: { type: "integer", default: 0 } },
          { name: "status", in: "query", schema: { type: "string", enum: ["received", "verified", "in_progress", "resolved", "rejected"] } },
        ],
        responses: {
          "200": { description: "Reports retrieved successfully" },
          "401": { description: "Unauthorized" },
        },
      },
    },
    "/api/reports/stats": {
      get: {
        tags: ["Reports"],
        summary: "Get report statistics",
        description: "Admin only - Get dashboard statistics",
        responses: {
          "200": { description: "Stats retrieved successfully" },
          "401": { description: "Unauthorized" },
          "403": { description: "Admin access required" },
        },
      },
    },
    "/api/reports/{id}": {
      get: {
        tags: ["Reports"],
        summary: "Get report details",
        parameters: [{ name: "id", in: "path", required: true, schema: { type: "string", format: "uuid" } }],
        responses: {
          "200": { description: "Report retrieved successfully" },
          "401": { description: "Unauthorized" },
          "404": { description: "Report not found" },
        },
      },
    },
    "/api/reports/{id}/status": {
      patch: {
        tags: ["Reports"],
        summary: "Update report status",
        parameters: [{ name: "id", in: "path", required: true, schema: { type: "string", format: "uuid" } }],
        requestBody: {
          required: true,
          content: {
            "application/json": {
              schema: {
                type: "object",
                properties: {
                  status: { type: "string", enum: ["received", "verified", "in_progress", "resolved", "rejected"] },
                  notes: { type: "string", maxLength: 1000 },
                },
                required: ["status"],
              },
            },
          },
        },
        responses: {
          "200": { description: "Report status updated successfully" },
          "400": { description: "Validation error" },
          "401": { description: "Unauthorized" },
          "404": { description: "Report not found" },
        },
      },
    },
    "/api/risk-areas": {
      get: {
        tags: ["Risk Analysis"],
        summary: "Get Risk Areas",
        parameters: [
          { name: "lat", in: "query", schema: { type: "number" } },
          { name: "lng", in: "query", schema: { type: "number" } },
          { name: "radius", in: "query", schema: { type: "number" } },
          { name: "time_slot", in: "query", schema: { type: "string", enum: ["morning", "afternoon", "evening", "night"] } },
        ],
        responses: {
          "200": { description: "Risk areas retrieved successfully" },
          "400": { description: "Invalid coordinates" },
          "401": { description: "Unauthorized" },
        },
      },
    },
    "/api/route/safe": {
      post: {
        tags: ["Risk Analysis"],
        summary: "Calculate Safe Route",
        requestBody: {
          required: true,
          content: {
            "application/json": {
              schema: {
                type: "object",
                properties: {
                  start_lat: { type: "number" },
                  start_lng: { type: "number" },
                  end_lat: { type: "number" },
                  end_lng: { type: "number" },
                },
                required: ["start_lat", "start_lng", "end_lat", "end_lng"],
              },
            },
          },
        },
        responses: {
          "200": { description: "Safe route calculated" },
          "400": { description: "Validation error" },
          "401": { description: "Unauthorized" },
        },
      },
    },
    "/api/analysis/risk": {
      post: {
        tags: ["Risk Analysis"],
        summary: "Analyze Risk for Route",
        requestBody: {
          required: true,
          content: {
            "application/json": {
              schema: {
                type: "object",
                properties: {
                  start_lat: { type: "number" },
                  start_lng: { type: "number" },
                  end_lat: { type: "number" },
                  end_lng: { type: "number" },
                },
                required: ["start_lat", "start_lng", "end_lat", "end_lng"],
              },
            },
          },
        },
        responses: {
          "200": { description: "Risk analysis completed" },
          "400": { description: "Validation error" },
          "401": { description: "Unauthorized" },
        },
      },
    },
  },
};

export function setupSwagger(app: Express) {
  const html = `<!DOCTYPE html>
<html>
  <head>
    <title>Guardia API Documentation</title>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/swagger-ui-dist@5/swagger-ui.css">
  </head>
  <body>
    <div id="swagger-ui"></div>
    <script src="https://cdn.jsdelivr.net/npm/swagger-ui-dist@5/swagger-ui-bundle.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/swagger-ui-dist@5/swagger-ui-standalone-preset.js"></script>
    <script>
      window.onload = function () {
        SwaggerUIBundle({
          spec: ${JSON.stringify(swaggerSpec)},
          dom_id: '#swagger-ui',
          deepLinking: true,
          presets: [SwaggerUIBundle.presets.apis, SwaggerUIStandalonePreset],
          plugins: [SwaggerUIBundle.plugins.DownloadUrl],
          layout: 'StandaloneLayout',
        });
      };
    </script>
  </body>
</html>`;

  app.get("/docs", (_req, res) => {
    res.setHeader("Content-Type", "text/html");
    res.send(html);
  });
}
