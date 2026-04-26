package z2;

import O.RunnableC0093d;
import android.net.ConnectivityManager;
import android.net.Network;
import android.net.NetworkCapabilities;
import l3.C0523A;

/* JADX INFO: renamed from: z2.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0788a extends ConnectivityManager.NetworkCallback {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ b f6991a;

    public C0788a(b bVar) {
        this.f6991a = bVar;
    }

    @Override // android.net.ConnectivityManager.NetworkCallback
    public final void onAvailable(Network network) {
        b bVar = this.f6991a;
        bVar.f6994c.post(new RunnableC0093d(16, bVar, C0523A.c(((ConnectivityManager) bVar.f6992a.f5626a).getNetworkCapabilities(network))));
    }

    @Override // android.net.ConnectivityManager.NetworkCallback
    public final void onCapabilitiesChanged(Network network, NetworkCapabilities networkCapabilities) {
        b bVar = this.f6991a;
        bVar.f6992a.getClass();
        bVar.f6994c.post(new RunnableC0093d(16, bVar, C0523A.c(networkCapabilities)));
    }

    @Override // android.net.ConnectivityManager.NetworkCallback
    public final void onLost(Network network) {
        b bVar = this.f6991a;
        bVar.getClass();
        bVar.f6994c.postDelayed(new F1.a(bVar, 22), 500L);
    }
}
