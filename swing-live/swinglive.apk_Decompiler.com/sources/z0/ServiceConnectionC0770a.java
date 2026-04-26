package z0;

import android.content.ComponentName;
import android.content.ServiceConnection;
import android.os.IBinder;
import com.google.android.gms.common.internal.F;
import java.util.concurrent.LinkedBlockingQueue;

/* JADX INFO: renamed from: z0.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class ServiceConnectionC0770a implements ServiceConnection {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public boolean f6946a = false;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final LinkedBlockingQueue f6947b = new LinkedBlockingQueue();

    public final IBinder a() {
        F.f("BlockingServiceConnection.getService() called on main thread");
        if (this.f6946a) {
            throw new IllegalStateException("Cannot call get on this connection more than once");
        }
        this.f6946a = true;
        return (IBinder) this.f6947b.take();
    }

    @Override // android.content.ServiceConnection
    public final void onServiceConnected(ComponentName componentName, IBinder iBinder) {
        this.f6947b.add(iBinder);
    }

    @Override // android.content.ServiceConnection
    public final void onServiceDisconnected(ComponentName componentName) {
    }
}
