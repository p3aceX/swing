package z2;

import O.RunnableC0093d;
import O2.g;
import O2.h;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.net.ConnectivityManager;
import android.os.Handler;
import android.os.Looper;
import java.io.IOException;
import l3.C0523A;

/* JADX INFO: loaded from: classes.dex */
public final class b extends BroadcastReceiver implements h {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final C0523A f6992a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public g f6993b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final Handler f6994c = new Handler(Looper.getMainLooper());

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public C0788a f6995d;

    public b(Context context, C0523A c0523a) {
        this.f6992a = c0523a;
    }

    @Override // O2.h
    public final void a(g gVar) {
        this.f6993b = gVar;
        C0788a c0788a = new C0788a(this);
        this.f6995d = c0788a;
        C0523A c0523a = this.f6992a;
        ((ConnectivityManager) c0523a.f5626a).registerDefaultNetworkCallback(c0788a);
        ConnectivityManager connectivityManager = (ConnectivityManager) c0523a.f5626a;
        this.f6994c.post(new RunnableC0093d(16, this, C0523A.c(connectivityManager.getNetworkCapabilities(connectivityManager.getActiveNetwork()))));
    }

    @Override // O2.h
    public final void n() {
        C0788a c0788a = this.f6995d;
        if (c0788a != null) {
            ((ConnectivityManager) this.f6992a.f5626a).unregisterNetworkCallback(c0788a);
            this.f6995d = null;
        }
    }

    @Override // android.content.BroadcastReceiver
    public final void onReceive(Context context, Intent intent) throws IOException {
        g gVar = this.f6993b;
        if (gVar != null) {
            ConnectivityManager connectivityManager = (ConnectivityManager) this.f6992a.f5626a;
            gVar.a(C0523A.c(connectivityManager.getNetworkCapabilities(connectivityManager.getActiveNetwork())));
        }
    }
}
