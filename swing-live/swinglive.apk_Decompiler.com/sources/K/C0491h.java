package k;

import android.content.Context;
import android.graphics.drawable.Drawable;
import com.swing.live.R;
import e1.AbstractC0367g;
import u.AbstractC0686a;

/* JADX INFO: renamed from: k.h, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0491h extends C0500q implements InterfaceC0493j {

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ C0492i f5370c;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0491h(C0492i c0492i, Context context) {
        super(context, R.attr.actionOverflowButtonStyle);
        this.f5370c = c0492i;
        setClickable(true);
        setFocusable(true);
        setVisibility(0);
        setEnabled(true);
        AbstractC0367g.K(this, getContentDescription());
        setOnTouchListener(new j.a(this, this));
    }

    @Override // k.InterfaceC0493j
    public final boolean a() {
        return false;
    }

    @Override // k.InterfaceC0493j
    public final boolean b() {
        return false;
    }

    @Override // android.view.View
    public final boolean performClick() {
        if (super.performClick()) {
            return true;
        }
        playSoundEffect(0);
        this.f5370c.h();
        return true;
    }

    @Override // android.widget.ImageView
    public final boolean setFrame(int i4, int i5, int i6, int i7) {
        boolean frame = super.setFrame(i4, i5, i6, i7);
        Drawable drawable = getDrawable();
        Drawable background = getBackground();
        if (drawable != null && background != null) {
            int width = getWidth();
            int height = getHeight();
            int iMax = Math.max(width, height) / 2;
            int paddingLeft = (width + (getPaddingLeft() - getPaddingRight())) / 2;
            int paddingTop = (height + (getPaddingTop() - getPaddingBottom())) / 2;
            AbstractC0686a.f(background, paddingLeft - iMax, paddingTop - iMax, paddingLeft + iMax, paddingTop + iMax);
        }
        return frame;
    }
}
