package k;

import android.view.View;
import androidx.appcompat.widget.Toolbar;

/* JADX INFO: loaded from: classes.dex */
public final class k0 implements View.OnClickListener {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f5403a = 0;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ Object f5404b;

    public k0(p0 p0Var) {
        this.f5404b = p0Var;
        p0Var.f5425a.getContext();
    }

    @Override // android.view.View.OnClickListener
    public final void onClick(View view) {
        switch (this.f5403a) {
            case 0:
                l0 l0Var = ((Toolbar) this.f5404b).f2822O;
                j.k kVar = l0Var == null ? null : l0Var.f5406b;
                if (kVar != null) {
                    kVar.collapseActionView();
                }
                break;
            default:
                p0 p0Var = (p0) this.f5404b;
                if (p0Var.f5434k != null) {
                    p0Var.getClass();
                }
                break;
        }
    }

    public k0(Toolbar toolbar) {
        this.f5404b = toolbar;
    }
}
