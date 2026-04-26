package j;

import android.content.Context;
import android.graphics.drawable.Drawable;
import android.view.MenuItem;
import android.view.SubMenu;
import android.view.View;

/* JADX INFO: loaded from: classes.dex */
public final class t extends j implements SubMenu {
    public final j v;

    /* JADX INFO: renamed from: w, reason: collision with root package name */
    public final k f5155w;

    public t(Context context, j jVar, k kVar) {
        super(context);
        this.v = jVar;
        this.f5155w = kVar;
    }

    @Override // j.j
    public final boolean d(k kVar) {
        return this.v.d(kVar);
    }

    @Override // j.j
    public final boolean e(j jVar, MenuItem menuItem) {
        super.e(jVar, menuItem);
        return this.v.e(jVar, menuItem);
    }

    @Override // j.j
    public final boolean f(k kVar) {
        return this.v.f(kVar);
    }

    @Override // android.view.SubMenu
    public final MenuItem getItem() {
        return this.f5155w;
    }

    @Override // j.j
    public final j j() {
        return this.v.j();
    }

    @Override // j.j
    public final boolean l() {
        return this.v.l();
    }

    @Override // j.j
    public final boolean m() {
        return this.v.m();
    }

    @Override // j.j
    public final boolean n() {
        return this.v.n();
    }

    @Override // j.j, android.view.Menu
    public final void setGroupDividerEnabled(boolean z4) {
        this.v.setGroupDividerEnabled(z4);
    }

    @Override // android.view.SubMenu
    public final SubMenu setHeaderIcon(Drawable drawable) {
        q(0, null, 0, null);
        return this;
    }

    @Override // android.view.SubMenu
    public final SubMenu setHeaderTitle(CharSequence charSequence) {
        q(0, charSequence, 0, null);
        return this;
    }

    @Override // android.view.SubMenu
    public final SubMenu setHeaderView(View view) {
        q(0, null, 0, view);
        return this;
    }

    @Override // android.view.SubMenu
    public final SubMenu setIcon(Drawable drawable) {
        this.f5155w.setIcon(drawable);
        return this;
    }

    @Override // j.j, android.view.Menu
    public final void setQwertyMode(boolean z4) {
        this.v.setQwertyMode(z4);
    }

    @Override // android.view.SubMenu
    public final SubMenu setHeaderIcon(int i4) {
        q(0, null, i4, null);
        return this;
    }

    @Override // android.view.SubMenu
    public final SubMenu setHeaderTitle(int i4) {
        q(i4, null, 0, null);
        return this;
    }

    @Override // android.view.SubMenu
    public final SubMenu setIcon(int i4) {
        this.f5155w.setIcon(i4);
        return this;
    }
}
