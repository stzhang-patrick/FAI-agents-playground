# FAI-Agents-Playground

## Quick Start

```bash
# Build the image (includes .env.local)
docker build -t livekit-agents-playground:1.0 .

# Run the container
docker run -d \
    --name livekit-agents-playground \
    --network host \
    livekit-agents-playground:1.0
```

## Access the playground UI

Visit [http://localhost:3000](http://localhost:3000) in your browser to access the playground UI.
