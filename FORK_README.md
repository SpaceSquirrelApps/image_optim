# Fork Information

This is a fork of [toy/image_optim](https://github.com/toy/image_optim) with additional custom workers.

**Goal**: Keep in sync with upstream while maintaining custom features.

## Custom Workers Added

These workers are **not in upstream**:

- **cwebp** - WebP optimization (lossless & lossy)
- **cjpeg** - MozJPEG encoder
- **guetzli** - Google's perceptual JPEG encoder
- **zopflipng** - Zopfli PNG compression

## Modified Workers

These upstream workers have **additional options**:

- **gifsicle** - Added `lossy` option
- **pngquant** - Added `iebug` option for IE6 compatibility
- **jpegtran** - Added `strip_tags` option
- **jpegrecompress** - Enhanced implementation

## Tracking Changes for Upstream Syncs

### Files to watch during merges:
```
# Custom workers (keep ours)
lib/image_optim/worker/cwebp.rb
lib/image_optim/worker/cjpeg.rb
lib/image_optim/worker/guetzli.rb
lib/image_optim/worker/zopflipng.rb

# Modified workers (merge carefully - keep our options + their fixes)
lib/image_optim/worker/gifsicle.rb
lib/image_optim/worker/pngquant.rb
lib/image_optim/worker/jpegtran.rb
lib/image_optim/worker/jpegrecompress.rb

# Core (add version detection for custom workers)
lib/image_optim/bin_resolver/bin.rb
```

### Quick sync process:
```bash
git fetch upstream
git merge upstream/main
# Resolve conflicts - see list above
bundle exec rspec  # Test everything works
```

## Upstream
- **Upstream repo**: https://github.com/toy/image_optim
- **This fork**: https://github.com/SpaceSquirrelApps/image_optim
