package k;

import A.AbstractC0019t;
import android.content.Context;
import android.content.res.ColorStateList;
import android.content.res.TypedArray;
import android.graphics.PorterDuff;
import android.graphics.drawable.Drawable;
import android.util.AttributeSet;
import android.view.View;
import f.AbstractC0398a;
import java.lang.reflect.Field;
import y0.C0747k;

/* JADX INFO: renamed from: k.n, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0497n {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final View f5413a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final C0498o f5414b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f5415c = -1;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public Y.e f5416d;
    public Y.e e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public Y.e f5417f;

    public C0497n(View view) {
        C0498o c0498o;
        this.f5413a = view;
        PorterDuff.Mode mode = C0498o.f5418b;
        synchronized (C0498o.class) {
            try {
                if (C0498o.f5419c == null) {
                    C0498o.b();
                }
                c0498o = C0498o.f5419c;
            } catch (Throwable th) {
                throw th;
            }
        }
        this.f5414b = c0498o;
    }

    public final void a() {
        View view = this.f5413a;
        Drawable background = view.getBackground();
        if (background != null) {
            if (this.f5416d != null) {
                if (this.f5417f == null) {
                    this.f5417f = new Y.e();
                }
                Y.e eVar = this.f5417f;
                eVar.f2460c = null;
                eVar.f2459b = false;
                eVar.f2461d = null;
                eVar.f2458a = false;
                Field field = A.C.f4a;
                ColorStateList colorStateListG = AbstractC0019t.g(view);
                if (colorStateListG != null) {
                    eVar.f2459b = true;
                    eVar.f2460c = colorStateListG;
                }
                PorterDuff.Mode modeH = AbstractC0019t.h(view);
                if (modeH != null) {
                    eVar.f2458a = true;
                    eVar.f2461d = modeH;
                }
                if (eVar.f2459b || eVar.f2458a) {
                    C0498o.c(background, eVar, view.getDrawableState());
                    return;
                }
            }
            Y.e eVar2 = this.e;
            if (eVar2 != null) {
                C0498o.c(background, eVar2, view.getDrawableState());
                return;
            }
            Y.e eVar3 = this.f5416d;
            if (eVar3 != null) {
                C0498o.c(background, eVar3, view.getDrawableState());
            }
        }
    }

    public final void b(AttributeSet attributeSet, int i4) {
        ColorStateList colorStateListF;
        View view = this.f5413a;
        C0747k c0747kP = C0747k.P(view.getContext(), attributeSet, AbstractC0398a.f4263u, i4);
        TypedArray typedArray = (TypedArray) c0747kP.f6832c;
        try {
            if (typedArray.hasValue(0)) {
                this.f5415c = typedArray.getResourceId(0, -1);
                C0498o c0498o = this.f5414b;
                Context context = view.getContext();
                int i5 = this.f5415c;
                synchronized (c0498o) {
                    colorStateListF = c0498o.f5420a.f(context, i5);
                }
                if (colorStateListF != null) {
                    d(colorStateListF);
                }
            }
            if (typedArray.hasValue(1)) {
                ColorStateList colorStateListE = c0747kP.E(1);
                Field field = A.C.f4a;
                AbstractC0019t.q(view, colorStateListE);
            }
            if (typedArray.hasValue(2)) {
                PorterDuff.Mode modeC = AbstractC0508z.c(typedArray.getInt(2, -1), null);
                Field field2 = A.C.f4a;
                AbstractC0019t.r(view, modeC);
            }
        } finally {
            c0747kP.T();
        }
    }

    public final void c(int i4) {
        ColorStateList colorStateListF;
        this.f5415c = i4;
        C0498o c0498o = this.f5414b;
        if (c0498o != null) {
            Context context = this.f5413a.getContext();
            synchronized (c0498o) {
                colorStateListF = c0498o.f5420a.f(context, i4);
            }
        } else {
            colorStateListF = null;
        }
        d(colorStateListF);
        a();
    }

    public final void d(ColorStateList colorStateList) {
        if (colorStateList != null) {
            if (this.f5416d == null) {
                this.f5416d = new Y.e();
            }
            Y.e eVar = this.f5416d;
            eVar.f2460c = colorStateList;
            eVar.f2459b = true;
        } else {
            this.f5416d = null;
        }
        a();
    }

    public final void e(ColorStateList colorStateList) {
        if (this.e == null) {
            this.e = new Y.e();
        }
        Y.e eVar = this.e;
        eVar.f2460c = colorStateList;
        eVar.f2459b = true;
        a();
    }

    public final void f(PorterDuff.Mode mode) {
        if (this.e == null) {
            this.e = new Y.e();
        }
        Y.e eVar = this.e;
        eVar.f2461d = mode;
        eVar.f2458a = true;
        a();
    }
}
