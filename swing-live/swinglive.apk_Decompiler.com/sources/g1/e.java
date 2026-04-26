package g1;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import java.util.Iterator;
import java.util.concurrent.atomic.AtomicReference;

/* JADX INFO: loaded from: classes.dex */
public final class e extends BroadcastReceiver {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final AtomicReference f4303b = new AtomicReference();

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Context f4304a;

    public e(Context context) {
        this.f4304a = context;
    }

    @Override // android.content.BroadcastReceiver
    public final void onReceive(Context context, Intent intent) {
        synchronized (f.f4305i) {
            try {
                Iterator it = ((n.j) f.f4306j.values()).iterator();
                while (it.hasNext()) {
                    ((f) it.next()).f();
                }
            } catch (Throwable th) {
                throw th;
            }
        }
        this.f4304a.unregisterReceiver(this);
    }
}
