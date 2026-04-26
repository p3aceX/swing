package v0;

import B0.b;
import android.app.Activity;
import android.content.Context;
import com.google.android.gms.common.api.e;
import com.google.android.gms.common.api.h;
import com.google.android.gms.common.api.i;
import com.google.android.gms.common.api.k;
import com.google.android.gms.common.api.l;

/* JADX INFO: renamed from: v0.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public abstract class AbstractC0693a extends l {
    private static final h zza;
    private static final com.google.android.gms.common.api.a zzb;
    private static final i zzc;

    static {
        h hVar = new h();
        zza = hVar;
        b bVar = new b(7);
        zzb = bVar;
        zzc = new i("SmsRetriever.API", bVar, hVar);
    }

    public AbstractC0693a(Activity activity) {
        super(activity, activity, zzc, e.f3381j, k.f3499c);
    }

    public AbstractC0693a(Context context) {
        super(context, null, zzc, e.f3381j, k.f3499c);
    }
}
