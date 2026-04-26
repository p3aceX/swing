package k;

import android.graphics.drawable.Drawable;
import android.text.TextUtils;
import android.view.View;
import android.view.Window;
import androidx.appcompat.widget.Toolbar;

/* JADX INFO: loaded from: classes.dex */
public final class p0 implements InterfaceC0507y {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public Toolbar f5425a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f5426b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public View f5427c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public Drawable f5428d;
    public Drawable e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public Drawable f5429f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public boolean f5430g;

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public CharSequence f5431h;

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public CharSequence f5432i;

    /* JADX INFO: renamed from: j, reason: collision with root package name */
    public CharSequence f5433j;

    /* JADX INFO: renamed from: k, reason: collision with root package name */
    public Window.Callback f5434k;

    /* JADX INFO: renamed from: l, reason: collision with root package name */
    public int f5435l;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public Drawable f5436m;

    public final void a(int i4) {
        View view;
        int i5 = this.f5426b ^ i4;
        this.f5426b = i4;
        if (i5 != 0) {
            if ((i5 & 4) != 0) {
                if ((i4 & 4) != 0) {
                    b();
                }
                int i6 = this.f5426b & 4;
                Toolbar toolbar = this.f5425a;
                if (i6 != 0) {
                    Drawable drawable = this.f5429f;
                    if (drawable == null) {
                        drawable = this.f5436m;
                    }
                    toolbar.setNavigationIcon(drawable);
                } else {
                    toolbar.setNavigationIcon((Drawable) null);
                }
            }
            if ((i5 & 3) != 0) {
                c();
            }
            int i7 = i5 & 8;
            Toolbar toolbar2 = this.f5425a;
            if (i7 != 0) {
                if ((i4 & 8) != 0) {
                    toolbar2.setTitle(this.f5431h);
                    toolbar2.setSubtitle(this.f5432i);
                } else {
                    toolbar2.setTitle((CharSequence) null);
                    toolbar2.setSubtitle((CharSequence) null);
                }
            }
            if ((i5 & 16) == 0 || (view = this.f5427c) == null) {
                return;
            }
            if ((i4 & 16) != 0) {
                toolbar2.addView(view);
            } else {
                toolbar2.removeView(view);
            }
        }
    }

    public final void b() {
        if ((this.f5426b & 4) != 0) {
            boolean zIsEmpty = TextUtils.isEmpty(this.f5433j);
            Toolbar toolbar = this.f5425a;
            if (zIsEmpty) {
                toolbar.setNavigationContentDescription(this.f5435l);
            } else {
                toolbar.setNavigationContentDescription(this.f5433j);
            }
        }
    }

    public final void c() {
        Drawable drawable;
        int i4 = this.f5426b;
        if ((i4 & 2) == 0) {
            drawable = null;
        } else if ((i4 & 1) == 0 || (drawable = this.e) == null) {
            drawable = this.f5428d;
        }
        this.f5425a.setLogo(drawable);
    }
}
