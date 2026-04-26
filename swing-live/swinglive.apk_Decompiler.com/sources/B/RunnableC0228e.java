package b;

import android.content.Intent;
import android.content.IntentSender;
import u1.C0690c;

/* JADX INFO: renamed from: b.e, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class RunnableC0228e implements Runnable {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f3211a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ int f3212b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ C0229f f3213c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final /* synthetic */ Object f3214d;

    public /* synthetic */ RunnableC0228e(C0229f c0229f, int i4, Object obj, int i5) {
        this.f3211a = i5;
        this.f3213c = c0229f;
        this.f3212b = i4;
        this.f3214d = obj;
    }

    @Override // java.lang.Runnable
    public final void run() {
        switch (this.f3211a) {
            case 0:
                Object obj = ((C0690c) this.f3214d).f6642b;
                C0229f c0229f = this.f3213c;
                String str = (String) c0229f.f3215a.get(Integer.valueOf(this.f3212b));
                if (str != null) {
                    d.c cVar = (d.c) c0229f.e.get(str);
                    if (cVar == null) {
                        c0229f.f3220g.remove(str);
                        c0229f.f3219f.put(str, obj);
                    } else {
                        d.b bVar = cVar.f3877a;
                        if (c0229f.f3218d.remove(str)) {
                            bVar.k(obj);
                        }
                    }
                    break;
                }
                break;
            default:
                this.f3213c.a(this.f3212b, 0, new Intent().setAction("androidx.activity.result.contract.action.INTENT_SENDER_REQUEST").putExtra("androidx.activity.result.contract.extra.SEND_INTENT_EXCEPTION", (IntentSender.SendIntentException) this.f3214d));
                break;
        }
    }
}
