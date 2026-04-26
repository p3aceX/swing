package androidx.recyclerview.widget;

import B.k;
import J1.c;
import X.B;
import X.C0180k;
import X.t;
import X.u;
import android.content.Context;
import android.graphics.Rect;
import android.util.AttributeSet;
import android.util.Log;
import android.util.SparseIntArray;
import android.view.ViewGroup;
import com.google.crypto.tink.shaded.protobuf.S;

/* JADX INFO: loaded from: classes.dex */
public class GridLayoutManager extends LinearLayoutManager {

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public final int f3120p;

    /* JADX INFO: renamed from: q, reason: collision with root package name */
    public final k f3121q;

    public GridLayoutManager(Context context, AttributeSet attributeSet, int i4, int i5) {
        super(context, attributeSet, i4, i5);
        this.f3120p = -1;
        new SparseIntArray();
        new SparseIntArray();
        k kVar = new k(17);
        this.f3121q = kVar;
        new Rect();
        int i6 = t.w(context, attributeSet, i4, i5).f2361c;
        if (i6 == this.f3120p) {
            return;
        }
        if (i6 < 1) {
            throw new IllegalArgumentException(S.d(i6, "Span count should be at least 1. Provided "));
        }
        this.f3120p = i6;
        ((SparseIntArray) kVar.f104b).clear();
        H();
    }

    @Override // androidx.recyclerview.widget.LinearLayoutManager
    public final void Q(boolean z4) {
        if (z4) {
            throw new UnsupportedOperationException("GridLayoutManager does not support stack from end. Consider using reverse layout");
        }
        super.Q(false);
    }

    public final int R(c cVar, B b5, int i4) {
        boolean z4 = b5.f2276c;
        k kVar = this.f3121q;
        if (!z4) {
            int i5 = this.f3120p;
            kVar.getClass();
            return k.t(i4, i5);
        }
        RecyclerView recyclerView = (RecyclerView) cVar.f788g;
        B b6 = recyclerView.f3162d0;
        if (i4 < 0 || i4 >= b6.a()) {
            StringBuilder sbI = S.i("invalid position ", i4, ". State item count is ");
            sbI.append(b6.a());
            sbI.append(recyclerView.h());
            throw new IndexOutOfBoundsException(sbI.toString());
        }
        int iC = !b6.f2276c ? i4 : recyclerView.f3159c.C(i4, 0);
        if (iC != -1) {
            int i6 = this.f3120p;
            kVar.getClass();
            return k.t(iC, i6);
        }
        Log.w("GridLayoutManager", "Cannot find span size for pre layout position. " + i4);
        return 0;
    }

    @Override // X.t
    public final boolean d(u uVar) {
        return uVar instanceof C0180k;
    }

    @Override // androidx.recyclerview.widget.LinearLayoutManager, X.t
    public final u l() {
        return this.f3122h == 0 ? new C0180k(-2, -1) : new C0180k(-1, -2);
    }

    @Override // X.t
    public final u m(Context context, AttributeSet attributeSet) {
        return new C0180k(context, attributeSet);
    }

    @Override // X.t
    public final u n(ViewGroup.LayoutParams layoutParams) {
        return layoutParams instanceof ViewGroup.MarginLayoutParams ? new C0180k((ViewGroup.MarginLayoutParams) layoutParams) : new C0180k(layoutParams);
    }

    @Override // X.t
    public final int q(c cVar, B b5) {
        if (this.f3122h == 1) {
            return this.f3120p;
        }
        if (b5.a() < 1) {
            return 0;
        }
        return R(cVar, b5, b5.a() - 1) + 1;
    }

    @Override // X.t
    public final int x(c cVar, B b5) {
        if (this.f3122h == 0) {
            return this.f3120p;
        }
        if (b5.a() < 1) {
            return 0;
        }
        return R(cVar, b5, b5.a() - 1) + 1;
    }
}
