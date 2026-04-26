package e3;

import K.j;
import T2.RunnableC0169n;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Handler;
import y0.C0747k;

/* JADX INFO: renamed from: e3.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0397a extends BroadcastReceiver {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ b f4233a;

    public C0397a(b bVar) {
        this.f4233a = bVar;
    }

    @Override // android.content.BroadcastReceiver
    public final void onReceive(Context context, Intent intent) {
        b bVar = this.f4233a;
        int iB = bVar.b();
        if (!j.a(iB, bVar.e)) {
            C0747k c0747k = bVar.f4236b;
            ((Handler) c0747k.f6831b).post(new RunnableC0169n(c0747k, iB, 0));
        }
        bVar.e = iB;
    }
}
