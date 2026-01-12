import type { Plugin } from "@opencode-ai/plugin";

export const notification: Plugin = async ({ $ }) => {
  const isMacOs = process.platform === "darwin";
  if (!isMacOs) return {};

  return {
    event: async ({ event }) => {
      if (event.type !== "session.idle") return;

      await $`osascript -e "display notification \"Task completed\" with title \"Opencode\" sound name \"Glass\""`;
      await $`open -g "raycast://extensions/raycast/raycast/confetti"`;
    },
  };
};
