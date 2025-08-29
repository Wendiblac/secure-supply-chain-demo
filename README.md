# Secure Supply Chain Demo  

This repository demonstrates a **modern secure software supply chain workflow** built with **GitHub Actions, Cosign, SBOMs, and Provenance attestations**.  

The project automatically builds a container image, pushes it to GitHub Container Registry (GHCR), cryptographically signs it using **Sigstore Cosign**, and attaches **SBOM (Software Bill of Materials)** and **SLSA provenance attestations** — ensuring end-to-end integrity, authenticity, and traceability of the build.  

---

## What This Project Does  

When you push to `main`:  

1. **Build Container Image**  
   - Uses `docker/buildx` to build a container image from the repo’s `Dockerfile`.  
   - Outputs both the image and a cryptographic **digest** (`sha256:...`).  

2. **Push to GHCR**  
   - Publishes the built image to **GitHub Container Registry (GHCR)** under:  
     ```
     ghcr.io/wendiblac/secure-supply-chain-demo
     ```

3. **Generate SBOM + Provenance**  
   - The build step also generates a **Software Bill of Materials (SBOM)** and a **SLSA provenance file** to describe how the image was built.  
   - These artifacts are published alongside the image in GHCR.  

4. **Sign the Image (Cosign Keyless)**  
   - Installs **Cosign** via GitHub Actions.  
   - Signs the pushed image **by digest** using **keyless signing** (OIDC + Sigstore).  
   - Signature + certificate are uploaded to the **transparency log (Rekor)**.  

---

## Tech Stack  

- **Docker Buildx** → multi-arch builds, SBOM, provenance  
- **GHCR** → container registry for storing images  
- **Cosign (Sigstore)** → signing & verification  
- **GitHub Actions** → automation of the secure build pipeline  

---

## Why Secure Supply Chains?  

Software supply chain attacks (like **SolarWinds**, **Codecov**, etc.) prove that traditional CI/CD pipelines are vulnerable. By securing the pipeline:  

- **Authenticity** → Consumers can verify that the image truly came from you.  
- **Traceability** → SBOM + provenance show exactly what went into the build.  
- **Transparency** → All signatures & attestations are logged in **public Rekor ledger**.  
- **Tamper resistance** → Attackers can’t swap or alter images without breaking verification.  

---

## GitHub Actions Workflow  

File: `.github/workflows/secure-build.yml`

### Key Steps
```yaml
- Checkout code
- Set up QEMU & Buildx
- Log in to GHCR
- Build & Push image (with SBOM + provenance)
- Install Cosign
- Cosign sign the image (by digest)
```

### Signing Example
```bash
cosign sign ghcr.io/wendiblac/secure-supply-chain-demo@sha256:fbcb5ae...
```

---

## How to Verify the Image  

Anyone can verify the signature:  

```bash
cosign verify ghcr.io/wendiblac/secure-supply-chain-demo:dev-v1   --certificate-identity "https://github.com/wendiblac/secure-supply-chain-demo/.github/workflows/secure-build.yml@refs/heads/main"   --certificate-oidc-issuer "https://token.actions.githubusercontent.com"
```

Expected result:  
- Image is signed  
- Certificate identity matches GitHub Actions OIDC issuer  
- Rekor transparency log entry exists  

---

## SBOM & Provenance  

The build automatically generates:  

- **SBOM** → describes all software dependencies and layers in the image.  
- **SLSA Provenance** → describes *who built the image, how, and when*.  

These are published with the container image in GHCR.  

---

## Step-by-Step for Beginners  

Follow these steps to **replicate and test the secure supply chain** yourself:  

### 1. Fork this Repository  
- Click **Fork** in the top-right corner of GitHub.  

### 2. Enable GitHub Actions  
- Go to your fork → **Actions tab** → enable workflows.  

### 3. Set up GitHub Container Registry (GHCR)  
- In your repo settings → Packages → enable GHCR.  
- Ensure you have `GHCR_TOKEN` or use your GitHub PAT with `write:packages` scope.  

### 4. Push Code to Main  
- Edit `Dockerfile` or `README.md` → commit → push.  
- GitHub Actions workflow runs automatically.  

### 5. Check Build Artifacts  
- Go to **Actions tab** → see logs of build, push, signing.  

### 6. Verify the Signed Image  
Install **Cosign** locally and run:  
```bash
cosign verify ghcr.io/<your-username>/secure-supply-chain-demo:dev-v1
```

### 7. Inspect SBOM & Provenance  
Pull SBOM & provenance from GHCR using Cosign:  
```bash
cosign download sbom ghcr.io/<your-username>/secure-supply-chain-demo:dev-v1
cosign download attestation ghcr.io/<your-username>/secure-supply-chain-demo:dev-v1
```

You’ll see JSON output describing dependencies and build process.  

---

## Resources & References  

- [Sigstore Cosign](https://docs.sigstore.dev/cosign/overview)  
- [SLSA Framework](https://slsa.dev)  
- [Docker Buildx](https://docs.docker.com/build/buildx/)  
- [GitHub Actions OIDC](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect)  

---

## Key Takeaways  

- You’re **signing by digest**, not tag → no accidental mismatches.  
- No long-lived keys → signing is **keyless** (OIDC token from GitHub).  
- Signatures + attestations are **tamper-proof** in Rekor.  
- Consumers can independently verify everything.  

This repo proves that **supply chain security is practical** and **CI/CD can be both automated and trustworthy**.  
