package Q0;

import android.content.ComponentName;
import android.content.ServiceConnection;
import android.os.IBinder;

/* JADX INFO: renamed from: Q0.b, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class ServiceConnectionC0116b implements ServiceConnection {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ c f1514a;

    public /* synthetic */ ServiceConnectionC0116b(c cVar) {
        this.f1514a = cVar;
    }

    @Override // android.content.ServiceConnection
    public final void onServiceConnected(ComponentName componentName, IBinder iBinder) {
        c cVar = this.f1514a;
        cVar.f1517b.b("ServiceConnectionImpl.onServiceConnected(%s)", componentName);
        cVar.a().post(new B(this, iBinder));
    }

    @Override // android.content.ServiceConnection
    public final void onServiceDisconnected(ComponentName componentName) {
        c cVar = this.f1514a;
        cVar.f1517b.b("ServiceConnectionImpl.onServiceDisconnected(%s)", componentName);
        cVar.a().post(new z(this, 1));
    }
}
