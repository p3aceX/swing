package io.flutter.plugin.platform;

import android.media.ImageReader;
import android.os.Build;
import android.os.Handler;
import android.view.Surface;
import io.flutter.view.TextureRegistry$ImageTextureEntry;

/* JADX INFO: renamed from: io.flutter.plugin.platform.c, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0427c implements h {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public TextureRegistry$ImageTextureEntry f4618a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public ImageReader f4619b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f4620c = 0;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f4621d = 0;
    public final Handler e = new Handler();

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final C0426b f4622f = new C0426b(this);

    public C0427c(TextureRegistry$ImageTextureEntry textureRegistry$ImageTextureEntry) {
        if (Build.VERSION.SDK_INT < 29) {
            throw new UnsupportedOperationException("ImageReaderPlatformViewRenderTarget requires API version 29+");
        }
        this.f4618a = textureRegistry$ImageTextureEntry;
    }

    @Override // io.flutter.plugin.platform.h
    public final long b() {
        return this.f4618a.id();
    }

    @Override // io.flutter.plugin.platform.h
    public final void d(int i4, int i5) {
        ImageReader imageReaderNewInstance;
        ImageReader imageReader = this.f4619b;
        if (imageReader != null && this.f4620c == i4 && this.f4621d == i5) {
            return;
        }
        if (imageReader != null) {
            this.f4618a.pushImage(null);
            this.f4619b.close();
            this.f4619b = null;
        }
        this.f4620c = i4;
        this.f4621d = i5;
        int i6 = Build.VERSION.SDK_INT;
        Handler handler = this.e;
        C0426b c0426b = this.f4622f;
        if (i6 >= 33) {
            B.c.n();
            ImageReader.Builder builderG = B.c.g(this.f4620c, this.f4621d);
            builderG.setMaxImages(4);
            builderG.setImageFormat(34);
            builderG.setUsage(256L);
            imageReaderNewInstance = builderG.build();
            imageReaderNewInstance.setOnImageAvailableListener(c0426b, handler);
        } else {
            if (i6 < 29) {
                throw new UnsupportedOperationException("ImageReaderPlatformViewRenderTarget requires API version 29+");
            }
            imageReaderNewInstance = ImageReader.newInstance(i4, i5, 34, 4, 256L);
            imageReaderNewInstance.setOnImageAvailableListener(c0426b, handler);
        }
        this.f4619b = imageReaderNewInstance;
    }

    @Override // io.flutter.plugin.platform.h
    public final int getHeight() {
        return this.f4621d;
    }

    @Override // io.flutter.plugin.platform.h
    public final Surface getSurface() {
        return this.f4619b.getSurface();
    }

    @Override // io.flutter.plugin.platform.h
    public final int getWidth() {
        return this.f4620c;
    }

    @Override // io.flutter.plugin.platform.h
    public final void release() {
        if (this.f4619b != null) {
            this.f4618a.pushImage(null);
            this.f4619b.close();
            this.f4619b = null;
        }
        this.f4618a = null;
    }
}
