package k;

import android.content.Context;
import android.view.View;
import com.swing.live.R;
import u1.C0690c;

/* JADX INFO: renamed from: k.f, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0489f extends j.n {

    /* JADX INFO: renamed from: l, reason: collision with root package name */
    public final /* synthetic */ int f5351l = 1;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final /* synthetic */ C0492i f5352m;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0489f(C0492i c0492i, Context context, j.j jVar, View view) {
        super(R.attr.actionOverflowMenuStyle, context, view, jVar, true);
        this.f5352m = c0492i;
        this.f5132f = 8388613;
        C0690c c0690c = c0492i.f5378B;
        this.f5134h = c0690c;
        j.l lVar = this.f5135i;
        if (lVar != null) {
            lVar.j(c0690c);
        }
    }

    @Override // j.n
    public final void c() {
        switch (this.f5351l) {
            case 0:
                C0492i c0492i = this.f5352m;
                c0492i.f5395y = null;
                c0492i.getClass();
                super.c();
                break;
            default:
                C0492i c0492i2 = this.f5352m;
                j.j jVar = c0492i2.f5381c;
                if (jVar != null) {
                    jVar.c(true);
                }
                c0492i2.f5394x = null;
                super.c();
                break;
        }
    }

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0489f(C0492i c0492i, Context context, j.t tVar, View view) {
        super(R.attr.actionOverflowMenuStyle, context, view, tVar, false);
        this.f5352m = c0492i;
        if ((tVar.f5155w.f5123x & 32) != 32) {
            View view2 = c0492i.f5385n;
            this.e = view2 == null ? c0492i.f5384m : view2;
        }
        C0690c c0690c = c0492i.f5378B;
        this.f5134h = c0690c;
        j.l lVar = this.f5135i;
        if (lVar != null) {
            lVar.j(c0690c);
        }
    }
}
