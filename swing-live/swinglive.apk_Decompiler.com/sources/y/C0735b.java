package y;

import android.os.Build;
import android.text.PrecomputedText;
import android.text.TextDirectionHeuristic;
import android.text.TextPaint;
import android.text.TextUtils;
import i0.m;
import java.util.Objects;

/* JADX INFO: renamed from: y.b, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0735b {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final TextPaint f6799a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final TextDirectionHeuristic f6800b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final int f6801c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final int f6802d;

    public C0735b(TextPaint textPaint, TextDirectionHeuristic textDirectionHeuristic, int i4, int i5) {
        if (Build.VERSION.SDK_INT >= 29) {
            m.g(textPaint).setBreakStrategy(i4).setHyphenationFrequency(i5).setTextDirection(textDirectionHeuristic).build();
        }
        this.f6799a = textPaint;
        this.f6800b = textDirectionHeuristic;
        this.f6801c = i4;
        this.f6802d = i5;
    }

    public final boolean equals(Object obj) {
        if (obj == this) {
            return true;
        }
        if (!(obj instanceof C0735b)) {
            return false;
        }
        C0735b c0735b = (C0735b) obj;
        if (this.f6801c != c0735b.f6801c || this.f6802d != c0735b.f6802d) {
            return false;
        }
        TextPaint textPaint = this.f6799a;
        float textSize = textPaint.getTextSize();
        TextPaint textPaint2 = c0735b.f6799a;
        if (textSize != textPaint2.getTextSize() || textPaint.getTextScaleX() != textPaint2.getTextScaleX() || textPaint.getTextSkewX() != textPaint2.getTextSkewX() || textPaint.getLetterSpacing() != textPaint2.getLetterSpacing() || !TextUtils.equals(textPaint.getFontFeatureSettings(), textPaint2.getFontFeatureSettings()) || textPaint.getFlags() != textPaint2.getFlags() || !textPaint.getTextLocales().equals(textPaint2.getTextLocales())) {
            return false;
        }
        if (textPaint.getTypeface() == null) {
            if (textPaint2.getTypeface() != null) {
                return false;
            }
        } else if (!textPaint.getTypeface().equals(textPaint2.getTypeface())) {
            return false;
        }
        return this.f6800b == c0735b.f6800b;
    }

    public final int hashCode() {
        TextPaint textPaint = this.f6799a;
        return Objects.hash(Float.valueOf(textPaint.getTextSize()), Float.valueOf(textPaint.getTextScaleX()), Float.valueOf(textPaint.getTextSkewX()), Float.valueOf(textPaint.getLetterSpacing()), Integer.valueOf(textPaint.getFlags()), textPaint.getTextLocales(), textPaint.getTypeface(), Boolean.valueOf(textPaint.isElegantTextHeight()), this.f6800b, Integer.valueOf(this.f6801c), Integer.valueOf(this.f6802d));
    }

    public final String toString() {
        StringBuilder sb = new StringBuilder("{");
        StringBuilder sb2 = new StringBuilder("textSize=");
        TextPaint textPaint = this.f6799a;
        sb2.append(textPaint.getTextSize());
        sb.append(sb2.toString());
        sb.append(", textScaleX=" + textPaint.getTextScaleX());
        sb.append(", textSkewX=" + textPaint.getTextSkewX());
        int i4 = Build.VERSION.SDK_INT;
        sb.append(", letterSpacing=" + textPaint.getLetterSpacing());
        sb.append(", elegantTextHeight=" + textPaint.isElegantTextHeight());
        sb.append(", textLocale=" + textPaint.getTextLocales());
        sb.append(", typeface=" + textPaint.getTypeface());
        if (i4 >= 26) {
            sb.append(", variationSettings=" + textPaint.getFontVariationSettings());
        }
        sb.append(", textDir=" + this.f6800b);
        sb.append(", breakStrategy=" + this.f6801c);
        sb.append(", hyphenationFrequency=" + this.f6802d);
        sb.append("}");
        return sb.toString();
    }

    public C0735b(PrecomputedText.Params params) {
        this.f6799a = params.getTextPaint();
        this.f6800b = params.getTextDirection();
        this.f6801c = params.getBreakStrategy();
        this.f6802d = params.getHyphenationFrequency();
    }
}
