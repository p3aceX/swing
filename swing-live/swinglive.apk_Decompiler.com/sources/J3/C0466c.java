package j3;

import D2.AbstractActivityC0029d;
import I.C0053n;
import K.j;
import O2.k;
import O2.o;
import T2.t;
import X.N;
import Y0.n;
import android.accounts.Account;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import com.google.android.gms.auth.UserRecoverableAuthException;
import com.google.android.gms.auth.api.signin.GoogleSignInAccount;
import com.google.android.gms.auth.api.signin.GoogleSignInOptions;
import com.google.android.gms.common.api.Scope;
import com.google.android.gms.common.api.Status;
import com.google.android.gms.common.internal.F;
import com.google.android.gms.tasks.RuntimeExecutionException;
import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.Tasks;
import com.google.crypto.tink.shaded.protobuf.S;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Objects;
import q0.AbstractC0630d;
import s0.AbstractC0660a;
import x0.C0713a;
import x0.C0714b;
import x0.C0715c;
import y0.AbstractC0746j;

/* JADX INFO: renamed from: j3.c, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0466c implements o {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Context f5229a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public AbstractActivityC0029d f5230b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public C0713a f5231c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public List f5232d;
    public n e;

    public C0466c(Context context, N n4) {
        this.f5229a = context;
    }

    public static boolean f(String str) {
        return str == null || str.isEmpty();
    }

    public static void i(O2.f fVar, C0466c c0466c) {
        p1.d dVarM = fVar.m(new k());
        C0470g c0470g = C0470g.f5243d;
        C0053n c0053n = new C0053n(fVar, "dev.flutter.pigeon.google_sign_in_android.GoogleSignInApi.init", c0470g, null, 5);
        if (c0466c != null) {
            c0053n.y(new C0465b(c0466c, 3));
        } else {
            c0053n.y(null);
        }
        C0053n c0053n2 = new C0053n(fVar, "dev.flutter.pigeon.google_sign_in_android.GoogleSignInApi.signInSilently", c0470g, null, 5);
        if (c0466c != null) {
            c0053n2.y(new C0465b(c0466c, 4));
        } else {
            c0053n2.y(null);
        }
        C0053n c0053n3 = new C0053n(fVar, "dev.flutter.pigeon.google_sign_in_android.GoogleSignInApi.signIn", c0470g, null, 5);
        if (c0466c != null) {
            c0053n3.y(new C0465b(c0466c, 5));
        } else {
            c0053n3.y(null);
        }
        C0053n c0053n4 = new C0053n(fVar, "dev.flutter.pigeon.google_sign_in_android.GoogleSignInApi.getAccessToken", c0470g, dVarM, 5);
        if (c0466c != null) {
            c0053n4.y(new C0465b(c0466c, 6));
        } else {
            c0053n4.y(null);
        }
        C0053n c0053n5 = new C0053n(fVar, "dev.flutter.pigeon.google_sign_in_android.GoogleSignInApi.signOut", c0470g, null, 5);
        if (c0466c != null) {
            c0053n5.y(new C0465b(c0466c, 7));
        } else {
            c0053n5.y(null);
        }
        C0053n c0053n6 = new C0053n(fVar, "dev.flutter.pigeon.google_sign_in_android.GoogleSignInApi.disconnect", c0470g, null, 5);
        if (c0466c != null) {
            c0053n6.y(new C0465b(c0466c, 8));
        } else {
            c0053n6.y(null);
        }
        C0053n c0053n7 = new C0053n(fVar, "dev.flutter.pigeon.google_sign_in_android.GoogleSignInApi.isSignedIn", c0470g, null, 5);
        if (c0466c != null) {
            c0053n7.y(new C0465b(c0466c, 9));
        } else {
            c0053n7.y(null);
        }
        C0053n c0053n8 = new C0053n(fVar, "dev.flutter.pigeon.google_sign_in_android.GoogleSignInApi.clearAuthCache", c0470g, dVarM, 5);
        if (c0466c != null) {
            c0053n8.y(new C0465b(c0466c, 10));
        } else {
            c0053n8.y(null);
        }
        C0053n c0053n9 = new C0053n(fVar, "dev.flutter.pigeon.google_sign_in_android.GoogleSignInApi.requestScopes", c0470g, null, 5);
        if (c0466c != null) {
            c0053n9.y(new C0465b(c0466c, 11));
        } else {
            c0053n9.y(null);
        }
    }

    @Override // O2.o
    public final boolean a(int i4, int i5, Intent intent) {
        C0715c c0715c;
        GoogleSignInAccount googleSignInAccount;
        n nVar = this.e;
        if (nVar != null) {
            switch (i4) {
                case 53293:
                    if (intent == null) {
                        c("sign_in_failed", "Signin failed");
                        return true;
                    }
                    C0.a aVar = AbstractC0746j.f6828a;
                    Status status = Status.f3374n;
                    Status status2 = (Status) intent.getParcelableExtra("googleSignInStatus");
                    GoogleSignInAccount googleSignInAccount2 = (GoogleSignInAccount) intent.getParcelableExtra("googleSignInAccount");
                    if (googleSignInAccount2 == null) {
                        if (status2 != null) {
                            status = status2;
                        }
                        c0715c = new C0715c(null, status);
                    } else {
                        c0715c = new C0715c(googleSignInAccount2, Status.f3372f);
                    }
                    Status status3 = c0715c.f6758a;
                    h((!status3.b() || (googleSignInAccount = c0715c.f6759b) == null) ? Tasks.forException(F.k(status3)) : Tasks.forResult(googleSignInAccount));
                    return true;
                case 53294:
                    if (i5 != -1) {
                        c("failed_to_recover_auth", "Failed attempt to recover authentication");
                        return true;
                    }
                    t tVar = (t) nVar.e;
                    Objects.requireNonNull(tVar);
                    Object obj = this.e.f2492f;
                    Objects.requireNonNull(obj);
                    this.e = null;
                    d((String) obj, Boolean.FALSE, tVar);
                    return true;
                case 53295:
                    Boolean boolValueOf = Boolean.valueOf(i5 == -1);
                    t tVar2 = (t) this.e.f2491d;
                    Objects.requireNonNull(tVar2);
                    tVar2.d(boolValueOf);
                    this.e = null;
                    return true;
            }
        }
        return false;
    }

    public final void b(String str, t tVar, t tVar2, t tVar3, t tVar4, Object obj) {
        if (this.e == null) {
            this.e = new n(str, tVar, tVar2, tVar3, tVar4, obj);
            return;
        }
        throw new IllegalStateException("Concurrent operations detected: " + ((String) this.e.f2488a) + ", " + str);
    }

    public final void c(String str, String str2) {
        n nVar = this.e;
        t tVar = (t) nVar.f2490c;
        if (tVar != null) {
            tVar.b(new C0468e(str, str2));
        } else {
            t tVar2 = (t) nVar.f2489b;
            if (tVar2 == null && (tVar2 = (t) nVar.f2491d) == null) {
                tVar2 = (t) nVar.e;
            }
            Objects.requireNonNull(tVar2);
            tVar2.b(new C0468e(str, str2));
        }
        this.e = null;
    }

    public final void d(final String str, final Boolean bool, final t tVar) {
        try {
            tVar.d(AbstractC0630d.b(this.f5229a, new Account(str, "com.google"), "oauth2:" + S.e(this.f5232d)));
        } catch (UserRecoverableAuthException e) {
            new Handler(Looper.getMainLooper()).post(new Runnable() { // from class: j3.a
                @Override // java.lang.Runnable
                public final void run() {
                    Intent intent;
                    C0466c c0466c = this.f5223a;
                    c0466c.getClass();
                    boolean zBooleanValue = bool.booleanValue();
                    UserRecoverableAuthException userRecoverableAuthException = e;
                    t tVar2 = tVar;
                    if (!zBooleanValue || c0466c.e != null) {
                        tVar2.b(new C0468e("user_recoverable_auth", userRecoverableAuthException.getLocalizedMessage()));
                        return;
                    }
                    AbstractActivityC0029d abstractActivityC0029d = c0466c.f5230b;
                    if (abstractActivityC0029d == null) {
                        tVar2.b(new C0468e("user_recoverable_auth", "Cannot recover auth because app is not in foreground. " + userRecoverableAuthException.getLocalizedMessage()));
                        return;
                    }
                    c0466c.b("getTokens", null, null, null, tVar2, str);
                    Intent intent2 = userRecoverableAuthException.f3316a;
                    if (intent2 == null) {
                        int iB = j.b(userRecoverableAuthException.f3317b);
                        if (iB == 0) {
                            Log.w("Auth", "Make sure that an intent was provided to class instantiation.");
                        } else if (iB == 1) {
                            Log.e("Auth", "This shouldn't happen. Gms API throwing this exception should support the recovery Intent.");
                        } else if (iB == 2) {
                            Log.e("Auth", "this instantiation of UserRecoverableAuthException doesn't support an Intent.");
                        }
                        intent = null;
                    } else {
                        intent = new Intent(intent2);
                    }
                    abstractActivityC0029d.startActivityForResult(intent, 53294);
                }
            });
        } catch (Exception e4) {
            tVar.b(new C0468e("exception", e4.getMessage()));
        }
    }

    public final void e(C0469f c0469f) {
        C0714b c0714b;
        int identifier;
        try {
            int iOrdinal = c0469f.f5238b.ordinal();
            if (iOrdinal == 0) {
                c0714b = new C0714b(GoogleSignInOptions.f3342q);
                c0714b.f6750a.add(GoogleSignInOptions.f3344s);
            } else {
                if (iOrdinal != 1) {
                    throw new IllegalStateException("Unknown signInOption");
                }
                c0714b = new C0714b(GoogleSignInOptions.f3343r);
            }
            String string = c0469f.e;
            if (!f(c0469f.f5240d) && f(string)) {
                Log.w("google_sign_in", "clientId is not supported on Android and is interpreted as serverClientId. Use serverClientId instead to suppress this warning.");
                string = c0469f.f5240d;
            }
            boolean zF = f(string);
            Context context = this.f5229a;
            if (zF && (identifier = context.getResources().getIdentifier("default_web_client_id", "string", context.getPackageName())) != 0) {
                string = context.getString(identifier);
            }
            if (!f(string)) {
                c0714b.f6753d = true;
                F.d(string);
                String str = c0714b.e;
                F.a("two different server client ids provided", str == null || str.equals(string));
                c0714b.e = string;
                boolean zBooleanValue = c0469f.f5241f.booleanValue();
                c0714b.f6751b = true;
                F.d(string);
                String str2 = c0714b.e;
                F.a("two different server client ids provided", str2 == null || str2.equals(string));
                c0714b.e = string;
                c0714b.f6752c = zBooleanValue;
            }
            List list = c0469f.f5237a;
            this.f5232d = list;
            Iterator it = list.iterator();
            while (it.hasNext()) {
                Scope scope = new Scope(1, (String) it.next());
                HashSet hashSet = c0714b.f6750a;
                hashSet.add(scope);
                hashSet.addAll(Arrays.asList(new Scope[0]));
            }
            if (!f(c0469f.f5239c)) {
                String str3 = c0469f.f5239c;
                F.d(str3);
                c0714b.f6755g = str3;
            }
            String str4 = c0469f.f5242g;
            if (!f(str4)) {
                F.d(str4);
                c0714b.f6754f = new Account(str4, "com.google");
            }
            this.f5231c = new C0713a(context, null, AbstractC0660a.f6471a, c0714b.a(), new com.google.android.gms.common.api.k(new N(2), Looper.getMainLooper()));
        } catch (Exception e) {
            throw new C0468e("exception", e.getMessage());
        }
    }

    public final void g(GoogleSignInAccount googleSignInAccount) {
        String str = googleSignInAccount.f3333d;
        String str2 = googleSignInAccount.f3335m;
        Uri uri = googleSignInAccount.f3334f;
        String string = uri != null ? uri.toString() : null;
        C0472i c0472i = new C0472i();
        c0472i.f5246a = googleSignInAccount.e;
        if (str == null) {
            throw new IllegalStateException("Nonnull field \"email\" is null.");
        }
        c0472i.f5247b = str;
        String str3 = googleSignInAccount.f3331b;
        if (str3 == null) {
            throw new IllegalStateException("Nonnull field \"id\" is null.");
        }
        c0472i.f5248c = str3;
        c0472i.f5249d = string;
        c0472i.e = googleSignInAccount.f3332c;
        c0472i.f5250f = str2;
        t tVar = (t) this.e.f2489b;
        Objects.requireNonNull(tVar);
        tVar.d(c0472i);
        this.e = null;
    }

    public final void h(Task task) {
        try {
            g((GoogleSignInAccount) task.getResult(com.google.android.gms.common.api.j.class));
        } catch (com.google.android.gms.common.api.j e) {
            int statusCode = e.getStatusCode();
            c(statusCode != 4 ? statusCode != 7 ? statusCode != 12501 ? "sign_in_failed" : "sign_in_canceled" : "network_error" : "sign_in_required", e.toString());
        } catch (RuntimeExecutionException e4) {
            c("exception", e4.toString());
        }
    }
}
