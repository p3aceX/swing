package j;

import android.content.Context;
import android.content.Intent;
import android.content.res.ColorStateList;
import android.graphics.PorterDuff;
import android.graphics.drawable.Drawable;
import android.view.ActionProvider;
import android.view.ContextMenu;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.MenuItem;
import android.view.SubMenu;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import g.AbstractC0404a;
import java.util.ArrayList;
import u.AbstractC0686a;

/* JADX INFO: loaded from: classes.dex */
public final class k implements MenuItem {

    /* JADX INFO: renamed from: A, reason: collision with root package name */
    public MenuItem.OnActionExpandListener f5100A;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f5102a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final int f5103b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final int f5104c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final int f5105d;
    public CharSequence e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public CharSequence f5106f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public Intent f5107g;

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public char f5108h;

    /* JADX INFO: renamed from: j, reason: collision with root package name */
    public char f5110j;

    /* JADX INFO: renamed from: l, reason: collision with root package name */
    public Drawable f5112l;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public final j f5114n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public t f5115o;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public MenuItem.OnMenuItemClickListener f5116p;

    /* JADX INFO: renamed from: q, reason: collision with root package name */
    public CharSequence f5117q;

    /* JADX INFO: renamed from: r, reason: collision with root package name */
    public CharSequence f5118r;

    /* JADX INFO: renamed from: z, reason: collision with root package name */
    public View f5125z;

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public int f5109i = 4096;

    /* JADX INFO: renamed from: k, reason: collision with root package name */
    public int f5111k = 4096;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public int f5113m = 0;

    /* JADX INFO: renamed from: s, reason: collision with root package name */
    public ColorStateList f5119s = null;

    /* JADX INFO: renamed from: t, reason: collision with root package name */
    public PorterDuff.Mode f5120t = null;

    /* JADX INFO: renamed from: u, reason: collision with root package name */
    public boolean f5121u = false;
    public boolean v = false;

    /* JADX INFO: renamed from: w, reason: collision with root package name */
    public boolean f5122w = false;

    /* JADX INFO: renamed from: x, reason: collision with root package name */
    public int f5123x = 16;

    /* JADX INFO: renamed from: B, reason: collision with root package name */
    public boolean f5101B = false;

    /* JADX INFO: renamed from: y, reason: collision with root package name */
    public int f5124y = 0;

    public k(j jVar, int i4, int i5, int i6, int i7, CharSequence charSequence) {
        this.f5114n = jVar;
        this.f5102a = i5;
        this.f5103b = i4;
        this.f5104c = i6;
        this.f5105d = i7;
        this.e = charSequence;
    }

    public static void a(StringBuilder sb, int i4, int i5, String str) {
        if ((i4 & i5) == i5) {
            sb.append(str);
        }
    }

    public final Drawable b(Drawable drawable) {
        if (drawable != null && this.f5122w && (this.f5121u || this.v)) {
            drawable = drawable.mutate();
            if (this.f5121u) {
                AbstractC0686a.h(drawable, this.f5119s);
            }
            if (this.v) {
                AbstractC0686a.i(drawable, this.f5120t);
            }
            this.f5122w = false;
        }
        return drawable;
    }

    public final k c(CharSequence charSequence) {
        this.f5117q = charSequence;
        this.f5114n.o(false);
        return this;
    }

    @Override // android.view.MenuItem
    public final boolean collapseActionView() {
        if ((this.f5124y & 8) == 0) {
            return false;
        }
        if (this.f5125z == null) {
            return true;
        }
        MenuItem.OnActionExpandListener onActionExpandListener = this.f5100A;
        if (onActionExpandListener == null || onActionExpandListener.onMenuItemActionCollapse(this)) {
            return this.f5114n.d(this);
        }
        return false;
    }

    public final void d(boolean z4) {
        if (z4) {
            this.f5123x |= 32;
        } else {
            this.f5123x &= -33;
        }
    }

    public final k e(CharSequence charSequence) {
        this.f5118r = charSequence;
        this.f5114n.o(false);
        return this;
    }

    @Override // android.view.MenuItem
    public final boolean expandActionView() {
        MenuItem.OnActionExpandListener onActionExpandListener;
        if ((((this.f5124y & 8) == 0 || this.f5125z == null) ? false : true) && ((onActionExpandListener = this.f5100A) == null || onActionExpandListener.onMenuItemActionExpand(this))) {
            return this.f5114n.f(this);
        }
        return false;
    }

    @Override // android.view.MenuItem
    public final ActionProvider getActionProvider() {
        throw new UnsupportedOperationException("This is not supported, use MenuItemCompat.getActionProvider()");
    }

    @Override // android.view.MenuItem
    public final View getActionView() {
        View view = this.f5125z;
        if (view != null) {
            return view;
        }
        return null;
    }

    @Override // android.view.MenuItem
    public final int getAlphabeticModifiers() {
        return this.f5111k;
    }

    @Override // android.view.MenuItem
    public final char getAlphabeticShortcut() {
        return this.f5110j;
    }

    @Override // android.view.MenuItem
    public final CharSequence getContentDescription() {
        return this.f5117q;
    }

    @Override // android.view.MenuItem
    public final int getGroupId() {
        return this.f5103b;
    }

    @Override // android.view.MenuItem
    public final Drawable getIcon() {
        Drawable drawable = this.f5112l;
        if (drawable != null) {
            return b(drawable);
        }
        int i4 = this.f5113m;
        if (i4 == 0) {
            return null;
        }
        Drawable drawableA = AbstractC0404a.a(this.f5114n.f5081a, i4);
        this.f5113m = 0;
        this.f5112l = drawableA;
        return b(drawableA);
    }

    @Override // android.view.MenuItem
    public final ColorStateList getIconTintList() {
        return this.f5119s;
    }

    @Override // android.view.MenuItem
    public final PorterDuff.Mode getIconTintMode() {
        return this.f5120t;
    }

    @Override // android.view.MenuItem
    public final Intent getIntent() {
        return this.f5107g;
    }

    @Override // android.view.MenuItem
    public final int getItemId() {
        return this.f5102a;
    }

    @Override // android.view.MenuItem
    public final ContextMenu.ContextMenuInfo getMenuInfo() {
        return null;
    }

    @Override // android.view.MenuItem
    public final int getNumericModifiers() {
        return this.f5109i;
    }

    @Override // android.view.MenuItem
    public final char getNumericShortcut() {
        return this.f5108h;
    }

    @Override // android.view.MenuItem
    public final int getOrder() {
        return this.f5104c;
    }

    @Override // android.view.MenuItem
    public final SubMenu getSubMenu() {
        return this.f5115o;
    }

    @Override // android.view.MenuItem
    public final CharSequence getTitle() {
        return this.e;
    }

    @Override // android.view.MenuItem
    public final CharSequence getTitleCondensed() {
        CharSequence charSequence = this.f5106f;
        return charSequence != null ? charSequence : this.e;
    }

    @Override // android.view.MenuItem
    public final CharSequence getTooltipText() {
        return this.f5118r;
    }

    @Override // android.view.MenuItem
    public final boolean hasSubMenu() {
        return this.f5115o != null;
    }

    @Override // android.view.MenuItem
    public final boolean isActionViewExpanded() {
        return this.f5101B;
    }

    @Override // android.view.MenuItem
    public final boolean isCheckable() {
        return (this.f5123x & 1) == 1;
    }

    @Override // android.view.MenuItem
    public final boolean isChecked() {
        return (this.f5123x & 2) == 2;
    }

    @Override // android.view.MenuItem
    public final boolean isEnabled() {
        return (this.f5123x & 16) != 0;
    }

    @Override // android.view.MenuItem
    public final boolean isVisible() {
        return (this.f5123x & 8) == 0;
    }

    @Override // android.view.MenuItem
    public final MenuItem setActionProvider(ActionProvider actionProvider) {
        throw new UnsupportedOperationException("This is not supported, use MenuItemCompat.setActionProvider()");
    }

    @Override // android.view.MenuItem
    public final MenuItem setActionView(View view) {
        int i4;
        this.f5125z = view;
        if (view != null && view.getId() == -1 && (i4 = this.f5102a) > 0) {
            view.setId(i4);
        }
        j jVar = this.f5114n;
        jVar.f5090k = true;
        jVar.o(true);
        return this;
    }

    @Override // android.view.MenuItem
    public final MenuItem setAlphabeticShortcut(char c5) {
        if (this.f5110j == c5) {
            return this;
        }
        this.f5110j = Character.toLowerCase(c5);
        this.f5114n.o(false);
        return this;
    }

    @Override // android.view.MenuItem
    public final MenuItem setCheckable(boolean z4) {
        int i4 = this.f5123x;
        int i5 = (z4 ? 1 : 0) | (i4 & (-2));
        this.f5123x = i5;
        if (i4 != i5) {
            this.f5114n.o(false);
        }
        return this;
    }

    @Override // android.view.MenuItem
    public final MenuItem setChecked(boolean z4) {
        int i4 = this.f5123x;
        if ((i4 & 4) == 0) {
            int i5 = (i4 & (-3)) | (z4 ? 2 : 0);
            this.f5123x = i5;
            if (i4 != i5) {
                this.f5114n.o(false);
            }
            return this;
        }
        j jVar = this.f5114n;
        jVar.getClass();
        ArrayList arrayList = jVar.f5085f;
        int size = arrayList.size();
        jVar.s();
        for (int i6 = 0; i6 < size; i6++) {
            k kVar = (k) arrayList.get(i6);
            if (kVar.f5103b == this.f5103b && (kVar.f5123x & 4) != 0 && kVar.isCheckable()) {
                boolean z5 = kVar == this;
                int i7 = kVar.f5123x;
                int i8 = (z5 ? 2 : 0) | (i7 & (-3));
                kVar.f5123x = i8;
                if (i7 != i8) {
                    kVar.f5114n.o(false);
                }
            }
        }
        jVar.r();
        return this;
    }

    @Override // android.view.MenuItem
    public final /* bridge */ /* synthetic */ MenuItem setContentDescription(CharSequence charSequence) {
        c(charSequence);
        return this;
    }

    @Override // android.view.MenuItem
    public final MenuItem setEnabled(boolean z4) {
        if (z4) {
            this.f5123x |= 16;
        } else {
            this.f5123x &= -17;
        }
        this.f5114n.o(false);
        return this;
    }

    @Override // android.view.MenuItem
    public final MenuItem setIcon(Drawable drawable) {
        this.f5113m = 0;
        this.f5112l = drawable;
        this.f5122w = true;
        this.f5114n.o(false);
        return this;
    }

    @Override // android.view.MenuItem
    public final MenuItem setIconTintList(ColorStateList colorStateList) {
        this.f5119s = colorStateList;
        this.f5121u = true;
        this.f5122w = true;
        this.f5114n.o(false);
        return this;
    }

    @Override // android.view.MenuItem
    public final MenuItem setIconTintMode(PorterDuff.Mode mode) {
        this.f5120t = mode;
        this.v = true;
        this.f5122w = true;
        this.f5114n.o(false);
        return this;
    }

    @Override // android.view.MenuItem
    public final MenuItem setIntent(Intent intent) {
        this.f5107g = intent;
        return this;
    }

    @Override // android.view.MenuItem
    public final MenuItem setNumericShortcut(char c5) {
        if (this.f5108h == c5) {
            return this;
        }
        this.f5108h = c5;
        this.f5114n.o(false);
        return this;
    }

    @Override // android.view.MenuItem
    public final MenuItem setOnActionExpandListener(MenuItem.OnActionExpandListener onActionExpandListener) {
        this.f5100A = onActionExpandListener;
        return this;
    }

    @Override // android.view.MenuItem
    public final MenuItem setOnMenuItemClickListener(MenuItem.OnMenuItemClickListener onMenuItemClickListener) {
        this.f5116p = onMenuItemClickListener;
        return this;
    }

    @Override // android.view.MenuItem
    public final MenuItem setShortcut(char c5, char c6) {
        this.f5108h = c5;
        this.f5110j = Character.toLowerCase(c6);
        this.f5114n.o(false);
        return this;
    }

    @Override // android.view.MenuItem
    public final void setShowAsAction(int i4) {
        int i5 = i4 & 3;
        if (i5 != 0 && i5 != 1 && i5 != 2) {
            throw new IllegalArgumentException("SHOW_AS_ACTION_ALWAYS, SHOW_AS_ACTION_IF_ROOM, and SHOW_AS_ACTION_NEVER are mutually exclusive.");
        }
        this.f5124y = i4;
        j jVar = this.f5114n;
        jVar.f5090k = true;
        jVar.o(true);
    }

    @Override // android.view.MenuItem
    public final MenuItem setShowAsActionFlags(int i4) {
        setShowAsAction(i4);
        return this;
    }

    @Override // android.view.MenuItem
    public final MenuItem setTitle(CharSequence charSequence) {
        this.e = charSequence;
        this.f5114n.o(false);
        t tVar = this.f5115o;
        if (tVar != null) {
            tVar.setHeaderTitle(charSequence);
        }
        return this;
    }

    @Override // android.view.MenuItem
    public final MenuItem setTitleCondensed(CharSequence charSequence) {
        this.f5106f = charSequence;
        this.f5114n.o(false);
        return this;
    }

    @Override // android.view.MenuItem
    public final /* bridge */ /* synthetic */ MenuItem setTooltipText(CharSequence charSequence) {
        e(charSequence);
        return this;
    }

    @Override // android.view.MenuItem
    public final MenuItem setVisible(boolean z4) {
        int i4 = this.f5123x;
        int i5 = (z4 ? 0 : 8) | (i4 & (-9));
        this.f5123x = i5;
        if (i4 != i5) {
            j jVar = this.f5114n;
            jVar.f5087h = true;
            jVar.o(true);
        }
        return this;
    }

    public final String toString() {
        CharSequence charSequence = this.e;
        if (charSequence != null) {
            return charSequence.toString();
        }
        return null;
    }

    @Override // android.view.MenuItem
    public final MenuItem setAlphabeticShortcut(char c5, int i4) {
        if (this.f5110j == c5 && this.f5111k == i4) {
            return this;
        }
        this.f5110j = Character.toLowerCase(c5);
        this.f5111k = KeyEvent.normalizeMetaState(i4);
        this.f5114n.o(false);
        return this;
    }

    @Override // android.view.MenuItem
    public final MenuItem setNumericShortcut(char c5, int i4) {
        if (this.f5108h == c5 && this.f5109i == i4) {
            return this;
        }
        this.f5108h = c5;
        this.f5109i = KeyEvent.normalizeMetaState(i4);
        this.f5114n.o(false);
        return this;
    }

    @Override // android.view.MenuItem
    public final MenuItem setShortcut(char c5, char c6, int i4, int i5) {
        this.f5108h = c5;
        this.f5109i = KeyEvent.normalizeMetaState(i4);
        this.f5110j = Character.toLowerCase(c6);
        this.f5111k = KeyEvent.normalizeMetaState(i5);
        this.f5114n.o(false);
        return this;
    }

    @Override // android.view.MenuItem
    public final MenuItem setIcon(int i4) {
        this.f5112l = null;
        this.f5113m = i4;
        this.f5122w = true;
        this.f5114n.o(false);
        return this;
    }

    @Override // android.view.MenuItem
    public final MenuItem setTitle(int i4) {
        setTitle(this.f5114n.f5081a.getString(i4));
        return this;
    }

    @Override // android.view.MenuItem
    public final MenuItem setActionView(int i4) {
        int i5;
        Context context = this.f5114n.f5081a;
        View viewInflate = LayoutInflater.from(context).inflate(i4, (ViewGroup) new LinearLayout(context), false);
        this.f5125z = viewInflate;
        if (viewInflate != null && viewInflate.getId() == -1 && (i5 = this.f5102a) > 0) {
            viewInflate.setId(i5);
        }
        j jVar = this.f5114n;
        jVar.f5090k = true;
        jVar.o(true);
        return this;
    }
}
