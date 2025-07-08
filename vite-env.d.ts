/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly VITE_API_ENDPOINT: string
  // add other environment variables here as needed
}

interface ImportMeta {
  readonly env: ImportMetaEnv
}
