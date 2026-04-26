package k;

import android.content.Context;
import android.content.res.Resources;
import android.graphics.RectF;
import android.os.Build;
import android.text.Layout;
import android.text.StaticLayout;
import android.text.TextDirectionHeuristic;
import android.text.TextDirectionHeuristics;
import android.text.TextPaint;
import android.text.method.TransformationMethod;
import android.util.Log;
import android.util.TypedValue;
import android.widget.TextView;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.concurrent.ConcurrentHashMap;

/* JADX INFO: renamed from: k.w, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0505w {

    /* JADX INFO: renamed from: k, reason: collision with root package name */
    public static final RectF f5478k = new RectF();

    /* JADX INFO: renamed from: l, reason: collision with root package name */
    public static final ConcurrentHashMap f5479l = new ConcurrentHashMap();

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f5480a = 0;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public boolean f5481b = false;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public float f5482c = -1.0f;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public float f5483d = -1.0f;
    public float e = -1.0f;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public int[] f5484f = new int[0];

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public boolean f5485g = false;

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public TextPaint f5486h;

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public final TextView f5487i;

    /* JADX INFO: renamed from: j, reason: collision with root package name */
    public final Context f5488j;

    static {
        new ConcurrentHashMap();
    }

    public C0505w(TextView textView) {
        this.f5487i = textView;
        this.f5488j = textView.getContext();
    }

    public static int[] b(int[] iArr) {
        int length = iArr.length;
        if (length != 0) {
            Arrays.sort(iArr);
            ArrayList arrayList = new ArrayList();
            for (int i4 : iArr) {
                if (i4 > 0 && Collections.binarySearch(arrayList, Integer.valueOf(i4)) < 0) {
                    arrayList.add(Integer.valueOf(i4));
                }
            }
            if (length != arrayList.size()) {
                int size = arrayList.size();
                int[] iArr2 = new int[size];
                for (int i5 = 0; i5 < size; i5++) {
                    iArr2[i5] = ((Integer) arrayList.get(i5)).intValue();
                }
                return iArr2;
            }
        }
        return iArr;
    }

    public static Method d(String str) {
        try {
            ConcurrentHashMap concurrentHashMap = f5479l;
            Method declaredMethod = (Method) concurrentHashMap.get(str);
            if (declaredMethod != null || (declaredMethod = TextView.class.getDeclaredMethod(str, new Class[0])) == null) {
                return declaredMethod;
            }
            declaredMethod.setAccessible(true);
            concurrentHashMap.put(str, declaredMethod);
            return declaredMethod;
        } catch (Exception e) {
            Log.w("ACTVAutoSizeHelper", "Failed to retrieve TextView#" + str + "() method", e);
            return null;
        }
    }

    public static Object e(Object obj, String str, Object obj2) {
        try {
            return d(str).invoke(obj, new Object[0]);
        } catch (Exception e) {
            Log.w("ACTVAutoSizeHelper", "Failed to invoke TextView#" + str + "() method", e);
            return obj2;
        }
    }

    public final void a() {
        if (this.f5480a != 0) {
            if (this.f5481b) {
                if (this.f5487i.getMeasuredHeight() <= 0 || this.f5487i.getMeasuredWidth() <= 0) {
                    return;
                }
                int measuredWidth = Build.VERSION.SDK_INT >= 29 ? this.f5487i.isHorizontallyScrollable() : ((Boolean) e(this.f5487i, "getHorizontallyScrolling", Boolean.FALSE)).booleanValue() ? 1048576 : (this.f5487i.getMeasuredWidth() - this.f5487i.getTotalPaddingLeft()) - this.f5487i.getTotalPaddingRight();
                int height = (this.f5487i.getHeight() - this.f5487i.getCompoundPaddingBottom()) - this.f5487i.getCompoundPaddingTop();
                if (measuredWidth <= 0 || height <= 0) {
                    return;
                }
                RectF rectF = f5478k;
                synchronized (rectF) {
                    try {
                        rectF.setEmpty();
                        rectF.right = measuredWidth;
                        rectF.bottom = height;
                        float fC = c(rectF);
                        if (fC != this.f5487i.getTextSize()) {
                            f(0, fC);
                        }
                    } finally {
                    }
                }
            }
            this.f5481b = true;
        }
    }

    public final int c(RectF rectF) {
        TextDirectionHeuristic textDirectionHeuristic;
        CharSequence transformation;
        int length = this.f5484f.length;
        if (length == 0) {
            throw new IllegalStateException("No available text sizes to choose from.");
        }
        int i4 = length - 1;
        int i5 = 1;
        int i6 = 0;
        while (i5 <= i4) {
            int i7 = (i5 + i4) / 2;
            int i8 = this.f5484f[i7];
            TextView textView = this.f5487i;
            CharSequence text = textView.getText();
            TransformationMethod transformationMethod = textView.getTransformationMethod();
            if (transformationMethod != null && (transformation = transformationMethod.getTransformation(text, textView)) != null) {
                text = transformation;
            }
            int i9 = Build.VERSION.SDK_INT;
            int maxLines = textView.getMaxLines();
            TextPaint textPaint = this.f5486h;
            if (textPaint == null) {
                this.f5486h = new TextPaint();
            } else {
                textPaint.reset();
            }
            this.f5486h.set(textView.getPaint());
            this.f5486h.setTextSize(i8);
            Layout.Alignment alignment = (Layout.Alignment) e(textView, "getLayoutAlignment", Layout.Alignment.ALIGN_NORMAL);
            StaticLayout.Builder builderObtain = StaticLayout.Builder.obtain(text, 0, text.length(), this.f5486h, Math.round(rectF.right));
            builderObtain.setAlignment(alignment).setLineSpacing(textView.getLineSpacingExtra(), textView.getLineSpacingMultiplier()).setIncludePad(textView.getIncludeFontPadding()).setBreakStrategy(textView.getBreakStrategy()).setHyphenationFrequency(textView.getHyphenationFrequency()).setMaxLines(maxLines == -1 ? com.google.android.gms.common.api.f.API_PRIORITY_OTHER : maxLines);
            if (i9 >= 29) {
                try {
                    textDirectionHeuristic = textView.getTextDirectionHeuristic();
                } catch (ClassCastException unused) {
                    Log.w("ACTVAutoSizeHelper", "Failed to obtain TextDirectionHeuristic, auto size may be incorrect");
                }
            } else {
                textDirectionHeuristic = (TextDirectionHeuristic) e(textView, "getTextDirectionHeuristic", TextDirectionHeuristics.FIRSTSTRONG_LTR);
            }
            builderObtain.setTextDirection(textDirectionHeuristic);
            StaticLayout staticLayoutBuild = builderObtain.build();
            if ((maxLines == -1 || (staticLayoutBuild.getLineCount() <= maxLines && staticLayoutBuild.getLineEnd(staticLayoutBuild.getLineCount() - 1) == text.length())) && staticLayoutBuild.getHeight() <= rectF.bottom) {
                int i10 = i7 + 1;
                i6 = i5;
                i5 = i10;
            } else {
                i6 = i7 - 1;
                i4 = i6;
            }
        }
        return this.f5484f[i6];
    }

    public final void f(int i4, float f4) {
        Context context = this.f5488j;
        float fApplyDimension = TypedValue.applyDimension(i4, f4, (context == null ? Resources.getSystem() : context.getResources()).getDisplayMetrics());
        TextView textView = this.f5487i;
        if (fApplyDimension != textView.getPaint().getTextSize()) {
            textView.getPaint().setTextSize(fApplyDimension);
            boolean zIsInLayout = textView.isInLayout();
            if (textView.getLayout() != null) {
                this.f5481b = false;
                try {
                    Method methodD = d("nullLayouts");
                    if (methodD != null) {
                        methodD.invoke(textView, new Object[0]);
                    }
                } catch (Exception e) {
                    Log.w("ACTVAutoSizeHelper", "Failed to invoke TextView#nullLayouts() method", e);
                }
                if (zIsInLayout) {
                    textView.forceLayout();
                } else {
                    textView.requestLayout();
                }
                textView.invalidate();
            }
        }
    }

    public final boolean g() {
        if (this.f5480a == 1) {
            if (!this.f5485g || this.f5484f.length == 0) {
                int iFloor = ((int) Math.floor((this.e - this.f5483d) / this.f5482c)) + 1;
                int[] iArr = new int[iFloor];
                for (int i4 = 0; i4 < iFloor; i4++) {
                    iArr[i4] = Math.round((i4 * this.f5482c) + this.f5483d);
                }
                this.f5484f = b(iArr);
            }
            this.f5481b = true;
        } else {
            this.f5481b = false;
        }
        return this.f5481b;
    }

    public final boolean h() {
        boolean z4 = this.f5484f.length > 0;
        this.f5485g = z4;
        if (z4) {
            this.f5480a = 1;
            this.f5483d = r0[0];
            this.e = r0[r1 - 1];
            this.f5482c = -1.0f;
        }
        return z4;
    }

    public final void i(float f4, float f5, float f6) {
        if (f4 <= 0.0f) {
            throw new IllegalArgumentException("Minimum auto-size text size (" + f4 + "px) is less or equal to (0px)");
        }
        if (f5 <= f4) {
            throw new IllegalArgumentException("Maximum auto-size text size (" + f5 + "px) is less or equal to minimum auto-size text size (" + f4 + "px)");
        }
        if (f6 <= 0.0f) {
            throw new IllegalArgumentException("The auto-size step granularity (" + f6 + "px) is less or equal to (0px)");
        }
        this.f5480a = 1;
        this.f5483d = f4;
        this.e = f5;
        this.f5482c = f6;
        this.f5485g = false;
    }
}
