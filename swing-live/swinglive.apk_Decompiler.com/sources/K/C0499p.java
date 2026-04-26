package k;

import android.content.Context;
import android.content.res.ColorStateList;
import android.graphics.Bitmap;
import android.graphics.PorterDuff;
import android.graphics.Rect;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.RippleDrawable;
import android.net.Uri;
import android.widget.ImageButton;
import android.widget.ImageView;
import com.swing.live.R;
import g.AbstractC0404a;

/* JADX INFO: renamed from: k.p, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0499p extends ImageButton {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final C0497n f5423a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final com.google.android.gms.common.internal.r f5424b;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0499p(Context context) {
        super(context, null, R.attr.toolbarNavigationButtonStyle);
        i0.a(context);
        C0497n c0497n = new C0497n(this);
        this.f5423a = c0497n;
        c0497n.b(null, R.attr.toolbarNavigationButtonStyle);
        com.google.android.gms.common.internal.r rVar = new com.google.android.gms.common.internal.r((ImageView) this);
        this.f5424b = rVar;
        rVar.B(R.attr.toolbarNavigationButtonStyle);
    }

    @Override // android.widget.ImageView, android.view.View
    public final void drawableStateChanged() {
        super.drawableStateChanged();
        C0497n c0497n = this.f5423a;
        if (c0497n != null) {
            c0497n.a();
        }
        com.google.android.gms.common.internal.r rVar = this.f5424b;
        if (rVar != null) {
            rVar.w();
        }
    }

    public ColorStateList getSupportBackgroundTintList() {
        Y.e eVar;
        C0497n c0497n = this.f5423a;
        if (c0497n == null || (eVar = c0497n.e) == null) {
            return null;
        }
        return (ColorStateList) eVar.f2460c;
    }

    public PorterDuff.Mode getSupportBackgroundTintMode() {
        Y.e eVar;
        C0497n c0497n = this.f5423a;
        if (c0497n == null || (eVar = c0497n.e) == null) {
            return null;
        }
        return (PorterDuff.Mode) eVar.f2461d;
    }

    public ColorStateList getSupportImageTintList() {
        Y.e eVar;
        com.google.android.gms.common.internal.r rVar = this.f5424b;
        if (rVar == null || (eVar = (Y.e) rVar.f3598c) == null) {
            return null;
        }
        return (ColorStateList) eVar.f2460c;
    }

    public PorterDuff.Mode getSupportImageTintMode() {
        Y.e eVar;
        com.google.android.gms.common.internal.r rVar = this.f5424b;
        if (rVar == null || (eVar = (Y.e) rVar.f3598c) == null) {
            return null;
        }
        return (PorterDuff.Mode) eVar.f2461d;
    }

    @Override // android.widget.ImageView, android.view.View
    public final boolean hasOverlappingRendering() {
        return !(((ImageView) this.f5424b.f3597b).getBackground() instanceof RippleDrawable) && super.hasOverlappingRendering();
    }

    @Override // android.view.View
    public void setBackgroundDrawable(Drawable drawable) {
        super.setBackgroundDrawable(drawable);
        C0497n c0497n = this.f5423a;
        if (c0497n != null) {
            c0497n.f5415c = -1;
            c0497n.d(null);
            c0497n.a();
        }
    }

    @Override // android.view.View
    public void setBackgroundResource(int i4) {
        super.setBackgroundResource(i4);
        C0497n c0497n = this.f5423a;
        if (c0497n != null) {
            c0497n.c(i4);
        }
    }

    @Override // android.widget.ImageView
    public void setImageBitmap(Bitmap bitmap) {
        super.setImageBitmap(bitmap);
        com.google.android.gms.common.internal.r rVar = this.f5424b;
        if (rVar != null) {
            rVar.w();
        }
    }

    @Override // android.widget.ImageView
    public void setImageDrawable(Drawable drawable) {
        super.setImageDrawable(drawable);
        com.google.android.gms.common.internal.r rVar = this.f5424b;
        if (rVar != null) {
            rVar.w();
        }
    }

    @Override // android.widget.ImageView
    public void setImageResource(int i4) {
        com.google.android.gms.common.internal.r rVar = this.f5424b;
        ImageView imageView = (ImageView) rVar.f3597b;
        if (i4 != 0) {
            Drawable drawableA = AbstractC0404a.a(imageView.getContext(), i4);
            if (drawableA != null) {
                Rect rect = AbstractC0508z.f5489a;
            }
            imageView.setImageDrawable(drawableA);
        } else {
            imageView.setImageDrawable(null);
        }
        rVar.w();
    }

    @Override // android.widget.ImageView
    public void setImageURI(Uri uri) {
        super.setImageURI(uri);
        com.google.android.gms.common.internal.r rVar = this.f5424b;
        if (rVar != null) {
            rVar.w();
        }
    }

    public void setSupportBackgroundTintList(ColorStateList colorStateList) {
        C0497n c0497n = this.f5423a;
        if (c0497n != null) {
            c0497n.e(colorStateList);
        }
    }

    public void setSupportBackgroundTintMode(PorterDuff.Mode mode) {
        C0497n c0497n = this.f5423a;
        if (c0497n != null) {
            c0497n.f(mode);
        }
    }

    public void setSupportImageTintList(ColorStateList colorStateList) {
        com.google.android.gms.common.internal.r rVar = this.f5424b;
        if (rVar != null) {
            if (((Y.e) rVar.f3598c) == null) {
                rVar.f3598c = new Y.e();
            }
            Y.e eVar = (Y.e) rVar.f3598c;
            eVar.f2460c = colorStateList;
            eVar.f2459b = true;
            rVar.w();
        }
    }

    public void setSupportImageTintMode(PorterDuff.Mode mode) {
        com.google.android.gms.common.internal.r rVar = this.f5424b;
        if (rVar != null) {
            if (((Y.e) rVar.f3598c) == null) {
                rVar.f3598c = new Y.e();
            }
            Y.e eVar = (Y.e) rVar.f3598c;
            eVar.f2461d = mode;
            eVar.f2458a = true;
            rVar.w();
        }
    }
}
