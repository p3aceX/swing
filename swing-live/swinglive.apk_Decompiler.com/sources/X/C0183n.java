package X;

import android.graphics.Rect;
import android.view.View;
import android.view.ViewGroup;

/* JADX INFO: renamed from: X.n, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0183n extends Q.b {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ int f2366b;

    public C0183n(t tVar, int i4) {
        this.f2366b = i4;
        new Rect();
        this.f1509a = tVar;
    }

    @Override // Q.b
    public final int c(View view) {
        switch (this.f2366b) {
            case 0:
                u uVar = (u) view.getLayoutParams();
                ((t) this.f1509a).getClass();
                return view.getRight() + ((u) view.getLayoutParams()).f2377a.right + ((ViewGroup.MarginLayoutParams) uVar).rightMargin;
            default:
                u uVar2 = (u) view.getLayoutParams();
                ((t) this.f1509a).getClass();
                return view.getBottom() + ((u) view.getLayoutParams()).f2377a.bottom + ((ViewGroup.MarginLayoutParams) uVar2).bottomMargin;
        }
    }

    @Override // Q.b
    public final int d(View view) {
        switch (this.f2366b) {
            case 0:
                u uVar = (u) view.getLayoutParams();
                ((t) this.f1509a).getClass();
                return (view.getLeft() - ((u) view.getLayoutParams()).f2377a.left) - ((ViewGroup.MarginLayoutParams) uVar).leftMargin;
            default:
                u uVar2 = (u) view.getLayoutParams();
                ((t) this.f1509a).getClass();
                return (view.getTop() - ((u) view.getLayoutParams()).f2377a.top) - ((ViewGroup.MarginLayoutParams) uVar2).topMargin;
        }
    }

    @Override // Q.b
    public final int e() {
        switch (this.f2366b) {
            case 0:
                t tVar = (t) this.f1509a;
                return tVar.f2375f - tVar.t();
            default:
                t tVar2 = (t) this.f1509a;
                return tVar2.f2376g - tVar2.r();
        }
    }

    @Override // Q.b
    public final int f() {
        switch (this.f2366b) {
            case 0:
                return ((t) this.f1509a).s();
            default:
                return ((t) this.f1509a).u();
        }
    }

    @Override // Q.b
    public final int g() {
        switch (this.f2366b) {
            case 0:
                t tVar = (t) this.f1509a;
                return (tVar.f2375f - tVar.s()) - tVar.t();
            default:
                t tVar2 = (t) this.f1509a;
                return (tVar2.f2376g - tVar2.u()) - tVar2.r();
        }
    }
}
