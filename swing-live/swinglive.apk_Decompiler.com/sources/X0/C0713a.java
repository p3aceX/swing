package x0;

import X.N;
import android.content.Context;
import android.content.Intent;
import com.google.android.gms.auth.api.signin.GoogleSignInOptions;
import com.google.android.gms.common.api.Status;
import com.google.android.gms.common.api.internal.BasePendingResult;
import com.google.android.gms.common.api.internal.C0272u;
import com.google.android.gms.common.api.internal.H;
import com.google.android.gms.common.api.l;
import com.google.android.gms.common.api.o;
import com.google.android.gms.common.api.x;
import com.google.android.gms.common.internal.F;
import com.google.android.gms.common.internal.z;
import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.TaskCompletionSource;
import y0.AbstractC0746j;
import y0.C0738b;
import y0.C0744h;
import y0.RunnableC0739c;
import z0.C0774e;

/* JADX INFO: renamed from: x0.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0713a extends l {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final f f6748a = new f();

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static int f6749b = 1;

    public final Intent c() {
        Context applicationContext = getApplicationContext();
        int iE = e();
        int i4 = iE - 1;
        if (iE == 0) {
            throw null;
        }
        if (i4 == 2) {
            GoogleSignInOptions googleSignInOptions = (GoogleSignInOptions) getApiOptions();
            AbstractC0746j.f6828a.a("getFallbackSignInIntent()", new Object[0]);
            Intent intentA = AbstractC0746j.a(applicationContext, googleSignInOptions);
            intentA.setAction("com.google.android.gms.auth.APPAUTH_SIGN_IN");
            return intentA;
        }
        if (i4 == 3) {
            return AbstractC0746j.a(applicationContext, (GoogleSignInOptions) getApiOptions());
        }
        GoogleSignInOptions googleSignInOptions2 = (GoogleSignInOptions) getApiOptions();
        AbstractC0746j.f6828a.a("getNoImplementationSignInIntent()", new Object[0]);
        Intent intentA2 = AbstractC0746j.a(applicationContext, googleSignInOptions2);
        intentA2.setAction("com.google.android.gms.auth.NO_IMPL");
        return intentA2;
    }

    public final Task d() {
        BasePendingResult basePendingResultDoWrite;
        o oVarAsGoogleApiClient = asGoogleApiClient();
        Context applicationContext = getApplicationContext();
        int i4 = 3;
        int i5 = 1;
        boolean z4 = e() == 3;
        AbstractC0746j.f6828a.a("Revoking access", new Object[0]);
        String strD = C0738b.a(applicationContext).d("refreshToken");
        AbstractC0746j.b(applicationContext);
        if (!z4) {
            basePendingResultDoWrite = ((H) oVarAsGoogleApiClient).f3412b.doWrite(new C0744h(oVarAsGoogleApiClient, i5));
        } else if (strD == null) {
            C0.a aVar = RunnableC0739c.f6810c;
            Status status = new Status(4, null);
            F.a("Status code must not be SUCCESS", !status.b());
            basePendingResultDoWrite = new x(status);
            basePendingResultDoWrite.setResult(status);
        } else {
            RunnableC0739c runnableC0739c = new RunnableC0739c(strD);
            new Thread(runnableC0739c).start();
            basePendingResultDoWrite = runnableC0739c.f6812b;
        }
        N n4 = new N(i4);
        TaskCompletionSource taskCompletionSource = new TaskCompletionSource();
        basePendingResultDoWrite.addStatusListener(new z(basePendingResultDoWrite, taskCompletionSource, n4));
        return taskCompletionSource.getTask();
    }

    public final synchronized int e() {
        int i4;
        try {
            i4 = f6749b;
            if (i4 == 1) {
                Context applicationContext = getApplicationContext();
                C0774e c0774e = C0774e.f6959d;
                int iC = c0774e.c(applicationContext, 12451000);
                if (iC == 0) {
                    i4 = 4;
                    f6749b = 4;
                } else if (c0774e.a(applicationContext, iC, null) != null || J0.a.a(applicationContext) == 0) {
                    i4 = 2;
                    f6749b = 2;
                } else {
                    i4 = 3;
                    f6749b = 3;
                }
            }
        } catch (Throwable th) {
            throw th;
        }
        return i4;
    }

    public final Task signOut() {
        BasePendingResult basePendingResultDoWrite;
        o oVarAsGoogleApiClient = asGoogleApiClient();
        Context applicationContext = getApplicationContext();
        boolean z4 = e() == 3;
        AbstractC0746j.f6828a.a("Signing out", new Object[0]);
        AbstractC0746j.b(applicationContext);
        if (z4) {
            Status status = Status.f3372f;
            basePendingResultDoWrite = new C0272u(oVarAsGoogleApiClient, 0);
            basePendingResultDoWrite.setResult(status);
        } else {
            basePendingResultDoWrite = ((H) oVarAsGoogleApiClient).f3412b.doWrite(new C0744h(oVarAsGoogleApiClient, 0));
        }
        N n4 = new N(3);
        TaskCompletionSource taskCompletionSource = new TaskCompletionSource();
        basePendingResultDoWrite.addStatusListener(new z(basePendingResultDoWrite, taskCompletionSource, n4));
        return taskCompletionSource.getTask();
    }
}
