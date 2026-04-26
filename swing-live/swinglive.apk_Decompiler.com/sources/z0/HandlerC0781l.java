package z0;

import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.os.Looper;
import android.os.Message;
import android.util.Log;
import com.google.android.gms.internal.base.zaq;
import com.google.android.gms.internal.common.zzd;

/* JADX INFO: renamed from: z0.l, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class HandlerC0781l extends zaq {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Context f6972a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ C0774e f6973b;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public HandlerC0781l(C0774e c0774e, Context context) {
        super(Looper.myLooper() == null ? Looper.getMainLooper() : Looper.myLooper());
        this.f6973b = c0774e;
        this.f6972a = context.getApplicationContext();
    }

    @Override // android.os.Handler
    public final void handleMessage(Message message) {
        int i4 = message.what;
        if (i4 != 1) {
            StringBuilder sb = new StringBuilder(50);
            sb.append("Don't know how to handle this message: ");
            sb.append(i4);
            Log.w("GoogleApiAvailability", sb.toString());
            return;
        }
        int i5 = C0775f.f6960a;
        C0774e c0774e = this.f6973b;
        Context context = this.f6972a;
        int iC = c0774e.c(context, i5);
        int i6 = AbstractC0778i.e;
        if (iC == 1 || iC == 2 || iC == 3 || iC == 9) {
            Intent intentA = c0774e.a(context, iC, "n");
            c0774e.g(context, iC, intentA == null ? null : PendingIntent.getActivity(context, 0, intentA, zzd.zza | 134217728));
        }
    }
}
