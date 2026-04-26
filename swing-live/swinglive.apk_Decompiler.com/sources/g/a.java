package G;

import android.database.DataSetObserver;
import k.AbstractC0483K;
import k.f0;

/* JADX INFO: loaded from: classes.dex */
public final class a extends DataSetObserver {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f474a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ Object f475b;

    public /* synthetic */ a(Object obj, int i4) {
        this.f474a = i4;
        this.f475b = obj;
    }

    @Override // android.database.DataSetObserver
    public final void onChanged() {
        switch (this.f474a) {
            case 0:
                f0 f0Var = (f0) this.f475b;
                f0Var.f476a = true;
                f0Var.notifyDataSetChanged();
                break;
            default:
                AbstractC0483K abstractC0483K = (AbstractC0483K) this.f475b;
                if (abstractC0483K.f5292B.isShowing()) {
                    abstractC0483K.b();
                }
                break;
        }
    }

    @Override // android.database.DataSetObserver
    public final void onInvalidated() {
        switch (this.f474a) {
            case 0:
                f0 f0Var = (f0) this.f475b;
                f0Var.f476a = false;
                f0Var.notifyDataSetInvalidated();
                break;
            default:
                ((AbstractC0483K) this.f475b).dismiss();
                break;
        }
    }
}
