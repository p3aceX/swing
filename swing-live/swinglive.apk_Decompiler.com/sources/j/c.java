package j;

import android.view.View;
import android.view.ViewTreeObserver;
import java.util.ArrayList;
import java.util.Iterator;
import k.N;

/* JADX INFO: loaded from: classes.dex */
public final class c implements ViewTreeObserver.OnGlobalLayoutListener {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f5041a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ l f5042b;

    public /* synthetic */ c(l lVar, int i4) {
        this.f5041a = i4;
        this.f5042b = lVar;
    }

    @Override // android.view.ViewTreeObserver.OnGlobalLayoutListener
    public final void onGlobalLayout() {
        switch (this.f5041a) {
            case 0:
                g gVar = (g) this.f5042b;
                if (gVar.g()) {
                    ArrayList arrayList = gVar.f5063n;
                    if (arrayList.size() > 0 && !((f) arrayList.get(0)).f5049a.f5291A) {
                        View view = gVar.f5070u;
                        if (view != null && view.isShown()) {
                            Iterator it = arrayList.iterator();
                            while (it.hasNext()) {
                                ((f) it.next()).f5049a.b();
                            }
                        } else {
                            gVar.dismiss();
                        }
                        break;
                    }
                }
                break;
            default:
                s sVar = (s) this.f5042b;
                if (sVar.g()) {
                    N n4 = sVar.f5143n;
                    if (!n4.f5291A) {
                        View view2 = sVar.f5148s;
                        if (view2 != null && view2.isShown()) {
                            n4.b();
                        } else {
                            sVar.dismiss();
                        }
                    }
                }
                break;
        }
    }
}
