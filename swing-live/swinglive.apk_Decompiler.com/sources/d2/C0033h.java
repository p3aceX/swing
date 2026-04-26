package D2;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.ColorSpace;
import android.graphics.Paint;
import android.hardware.HardwareBuffer;
import android.media.Image;
import android.media.ImageReader;
import android.os.Build;
import android.util.Log;
import android.view.Surface;
import android.view.View;
import java.nio.ByteBuffer;
import java.util.Locale;

/* JADX INFO: renamed from: D2.h, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public class C0033h extends View implements io.flutter.embedding.engine.renderer.m {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public ImageReader f204a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public Image f205b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public Bitmap f206c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public io.flutter.embedding.engine.renderer.j f207d;
    public final boolean e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final int f208f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public boolean f209m;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0033h(Context context, int i4, int i5, int i6) {
        super(context, null);
        ImageReader imageReaderF = f(i4, i5);
        this.e = false;
        this.f209m = false;
        this.f204a = imageReaderF;
        this.f208f = i6;
        setAlpha(0.0f);
        this.e = H0.a.K(getContext());
    }

    public static ImageReader f(int i4, int i5) {
        if (i4 <= 0) {
            Locale locale = Locale.US;
            Log.w("FlutterImageView", "ImageReader width must be greater than 0, but given width=" + i4 + ", set width=1");
            i4 = 1;
        }
        if (i5 <= 0) {
            Locale locale2 = Locale.US;
            Log.w("FlutterImageView", "ImageReader height must be greater than 0, but given height=" + i5 + ", set height=1");
            i5 = 1;
        }
        return Build.VERSION.SDK_INT >= 29 ? ImageReader.newInstance(i4, i5, 1, 3, 768L) : ImageReader.newInstance(i4, i5, 1, 3);
    }

    @Override // io.flutter.embedding.engine.renderer.m
    public final void b(io.flutter.embedding.engine.renderer.j jVar) {
        if (K.j.b(this.f208f) == 0) {
            Surface surface = this.f204a.getSurface();
            jVar.f4537c = surface;
            jVar.f4535a.onSurfaceWindowChanged(surface);
        }
        setAlpha(1.0f);
        this.f207d = jVar;
        this.f209m = true;
    }

    @Override // io.flutter.embedding.engine.renderer.m
    public final void d() {
        if (this.f209m) {
            setAlpha(0.0f);
            e();
            this.f206c = null;
            Image image = this.f205b;
            if (image != null) {
                image.close();
                this.f205b = null;
            }
            invalidate();
            this.f209m = false;
        }
    }

    public final boolean e() {
        if (!this.f209m) {
            return false;
        }
        Image imageAcquireLatestImage = this.f204a.acquireLatestImage();
        if (imageAcquireLatestImage != null) {
            Image image = this.f205b;
            if (image != null) {
                image.close();
                this.f205b = null;
            }
            this.f205b = imageAcquireLatestImage;
            invalidate();
        }
        return imageAcquireLatestImage != null;
    }

    public final void g(int i4, int i5) {
        if (this.f207d == null) {
            return;
        }
        if (i4 == this.f204a.getWidth() && i5 == this.f204a.getHeight()) {
            return;
        }
        Image image = this.f205b;
        if (image != null) {
            image.close();
            this.f205b = null;
        }
        this.f204a.close();
        this.f204a = f(i4, i5);
    }

    @Override // io.flutter.embedding.engine.renderer.m
    public io.flutter.embedding.engine.renderer.j getAttachedRenderer() {
        return this.f207d;
    }

    public ImageReader getImageReader() {
        return this.f204a;
    }

    public Surface getSurface() {
        return this.f204a.getSurface();
    }

    @Override // android.view.View
    public final void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        Image image = this.f205b;
        if (image != null) {
            if (Build.VERSION.SDK_INT >= 29) {
                HardwareBuffer hardwareBuffer = image.getHardwareBuffer();
                ColorSpace.Named unused = ColorSpace.Named.SRGB;
                this.f206c = Bitmap.wrapHardwareBuffer(hardwareBuffer, ColorSpace.get(ColorSpace.Named.SRGB));
                hardwareBuffer.close();
            } else {
                Image.Plane[] planes = image.getPlanes();
                if (planes.length == 1) {
                    Image.Plane plane = planes[0];
                    int rowStride = plane.getRowStride() / plane.getPixelStride();
                    int height = this.f205b.getHeight();
                    Bitmap bitmap = this.f206c;
                    if (bitmap == null || bitmap.getWidth() != rowStride || this.f206c.getHeight() != height) {
                        this.f206c = Bitmap.createBitmap(rowStride, height, Bitmap.Config.ARGB_8888);
                    }
                    ByteBuffer buffer = plane.getBuffer();
                    buffer.rewind();
                    this.f206c.copyPixelsFromBuffer(buffer);
                }
            }
        }
        Bitmap bitmap2 = this.f206c;
        if (bitmap2 != null) {
            canvas.drawBitmap(bitmap2, 0.0f, 0.0f, (Paint) null);
        }
    }

    @Override // android.view.View
    public final void onMeasure(int i4, int i5) {
        if (!this.e) {
            super.onMeasure(i4, i5);
            return;
        }
        int mode = View.MeasureSpec.getMode(i4);
        setMeasuredDimension(Math.max(View.MeasureSpec.getSize(i4), mode == 0 ? 1 : 0), Math.max(View.MeasureSpec.getSize(i5), View.MeasureSpec.getMode(i5) == 0 ? 1 : 0));
    }

    @Override // android.view.View
    public final void onSizeChanged(int i4, int i5, int i6, int i7) {
        if (!(i4 == this.f204a.getWidth() && i5 == this.f204a.getHeight()) && this.f208f == 1 && this.f209m) {
            g(i4, i5);
            io.flutter.embedding.engine.renderer.j jVar = this.f207d;
            Surface surface = this.f204a.getSurface();
            jVar.f4537c = surface;
            jVar.f4535a.onSurfaceWindowChanged(surface);
        }
    }

    @Override // io.flutter.embedding.engine.renderer.m
    public final void a() {
    }

    @Override // io.flutter.embedding.engine.renderer.m
    public final void c() {
    }
}
