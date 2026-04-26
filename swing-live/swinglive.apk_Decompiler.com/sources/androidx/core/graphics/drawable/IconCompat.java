package androidx.core.graphics.drawable;

import K.k;
import android.content.res.ColorStateList;
import android.graphics.Bitmap;
import android.graphics.BitmapShader;
import android.graphics.Canvas;
import android.graphics.Matrix;
import android.graphics.Paint;
import android.graphics.PorterDuff;
import android.graphics.Shader;
import android.net.Uri;
import android.os.Build;
import android.os.Parcelable;
import android.util.Log;
import androidx.versionedparcelable.CustomVersionedParcelable;
import java.lang.reflect.InvocationTargetException;
import u.b;
import u.d;

/* JADX INFO: loaded from: classes.dex */
public class IconCompat extends CustomVersionedParcelable {

    /* JADX INFO: renamed from: k, reason: collision with root package name */
    public static final PorterDuff.Mode f2857k = PorterDuff.Mode.SRC_IN;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public Object f2859b;

    /* JADX INFO: renamed from: j, reason: collision with root package name */
    public String f2866j;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f2858a = -1;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public byte[] f2860c = null;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public Parcelable f2861d = null;
    public int e = 0;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public int f2862f = 0;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public ColorStateList f2863g = null;

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public PorterDuff.Mode f2864h = f2857k;

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public String f2865i = null;

    public static Bitmap a(Bitmap bitmap, boolean z4) {
        int iMin = (int) (Math.min(bitmap.getWidth(), bitmap.getHeight()) * 0.6666667f);
        Bitmap bitmapCreateBitmap = Bitmap.createBitmap(iMin, iMin, Bitmap.Config.ARGB_8888);
        Canvas canvas = new Canvas(bitmapCreateBitmap);
        Paint paint = new Paint(3);
        float f4 = iMin;
        float f5 = 0.5f * f4;
        float f6 = 0.9166667f * f5;
        if (z4) {
            float f7 = 0.010416667f * f4;
            paint.setColor(0);
            paint.setShadowLayer(f7, 0.0f, f4 * 0.020833334f, 1023410176);
            canvas.drawCircle(f5, f5, f6, paint);
            paint.setShadowLayer(f7, 0.0f, 0.0f, 503316480);
            canvas.drawCircle(f5, f5, f6, paint);
            paint.clearShadowLayer();
        }
        paint.setColor(-16777216);
        Shader.TileMode tileMode = Shader.TileMode.CLAMP;
        BitmapShader bitmapShader = new BitmapShader(bitmap, tileMode, tileMode);
        Matrix matrix = new Matrix();
        matrix.setTranslate((-(bitmap.getWidth() - iMin)) / 2.0f, (-(bitmap.getHeight() - iMin)) / 2.0f);
        bitmapShader.setLocalMatrix(matrix);
        paint.setShader(bitmapShader);
        canvas.drawCircle(f5, f5, f6, paint);
        canvas.setBitmap(null);
        return bitmapCreateBitmap;
    }

    public static IconCompat b(int i4) {
        if (i4 == 0) {
            throw new IllegalArgumentException("Drawable resource ID must not be 0");
        }
        IconCompat iconCompat = new IconCompat();
        iconCompat.f2860c = null;
        iconCompat.f2861d = null;
        iconCompat.f2862f = 0;
        iconCompat.f2863g = null;
        iconCompat.f2864h = f2857k;
        iconCompat.f2865i = null;
        iconCompat.f2858a = 2;
        iconCompat.e = i4;
        iconCompat.f2859b = "";
        iconCompat.f2866j = "";
        return iconCompat;
    }

    public final int c() {
        int i4 = this.f2858a;
        if (i4 != -1) {
            if (i4 == 2) {
                return this.e;
            }
            throw new IllegalStateException("called getResId() on " + this);
        }
        int i5 = Build.VERSION.SDK_INT;
        Object obj = this.f2859b;
        if (i5 >= 28) {
            return d.a(obj);
        }
        try {
            return ((Integer) obj.getClass().getMethod("getResId", new Class[0]).invoke(obj, new Object[0])).intValue();
        } catch (IllegalAccessException e) {
            Log.e("IconCompat", "Unable to get icon resource", e);
            return 0;
        } catch (NoSuchMethodException e4) {
            Log.e("IconCompat", "Unable to get icon resource", e4);
            return 0;
        } catch (InvocationTargetException e5) {
            Log.e("IconCompat", "Unable to get icon resource", e5);
            return 0;
        }
    }

    public final Uri d() {
        int i4 = this.f2858a;
        if (i4 == -1) {
            return b.a(this.f2859b);
        }
        if (i4 == 4 || i4 == 6) {
            return Uri.parse((String) this.f2859b);
        }
        throw new IllegalStateException("called getUri() on " + this);
    }

    public final String toString() {
        String str;
        if (this.f2858a == -1) {
            return String.valueOf(this.f2859b);
        }
        StringBuilder sb = new StringBuilder("Icon(typ=");
        switch (this.f2858a) {
            case 1:
                str = "BITMAP";
                break;
            case 2:
                str = "RESOURCE";
                break;
            case 3:
                str = "DATA";
                break;
            case 4:
                str = "URI";
                break;
            case 5:
                str = "BITMAP_MASKABLE";
                break;
            case k.STRING_SET_FIELD_NUMBER /* 6 */:
                str = "URI_MASKABLE";
                break;
            default:
                str = "UNKNOWN";
                break;
        }
        sb.append(str);
        switch (this.f2858a) {
            case 1:
            case 5:
                sb.append(" size=");
                sb.append(((Bitmap) this.f2859b).getWidth());
                sb.append("x");
                sb.append(((Bitmap) this.f2859b).getHeight());
                break;
            case 2:
                sb.append(" pkg=");
                sb.append(this.f2866j);
                sb.append(" id=");
                sb.append(String.format("0x%08x", Integer.valueOf(c())));
                break;
            case 3:
                sb.append(" len=");
                sb.append(this.e);
                if (this.f2862f != 0) {
                    sb.append(" off=");
                    sb.append(this.f2862f);
                }
                break;
            case 4:
            case k.STRING_SET_FIELD_NUMBER /* 6 */:
                sb.append(" uri=");
                sb.append(this.f2859b);
                break;
        }
        if (this.f2863g != null) {
            sb.append(" tint=");
            sb.append(this.f2863g);
        }
        if (this.f2864h != f2857k) {
            sb.append(" mode=");
            sb.append(this.f2864h);
        }
        sb.append(")");
        return sb.toString();
    }
}
