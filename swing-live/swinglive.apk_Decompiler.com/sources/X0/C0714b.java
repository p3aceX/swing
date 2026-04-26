package x0;

import android.accounts.Account;
import com.google.android.gms.auth.api.signin.GoogleSignInOptions;
import com.google.android.gms.common.api.Scope;
import com.google.android.gms.common.internal.F;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;

/* JADX INFO: renamed from: x0.b, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0714b {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final HashSet f6750a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public boolean f6751b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public boolean f6752c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public boolean f6753d;
    public String e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public Account f6754f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public String f6755g;

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public final HashMap f6756h;

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public String f6757i;

    public C0714b() {
        this.f6750a = new HashSet();
        this.f6756h = new HashMap();
    }

    public final GoogleSignInOptions a() {
        Scope scope = GoogleSignInOptions.v;
        HashSet hashSet = this.f6750a;
        if (hashSet.contains(scope)) {
            Scope scope2 = GoogleSignInOptions.f3346u;
            if (hashSet.contains(scope2)) {
                hashSet.remove(scope2);
            }
        }
        if (this.f6753d && (this.f6754f == null || !hashSet.isEmpty())) {
            this.f6750a.add(GoogleSignInOptions.f3345t);
        }
        return new GoogleSignInOptions(3, new ArrayList(hashSet), this.f6754f, this.f6753d, this.f6751b, this.f6752c, this.e, this.f6755g, this.f6756h, this.f6757i);
    }

    public C0714b(GoogleSignInOptions googleSignInOptions) {
        this.f6750a = new HashSet();
        this.f6756h = new HashMap();
        F.g(googleSignInOptions);
        this.f6750a = new HashSet(googleSignInOptions.f3349b);
        this.f6751b = googleSignInOptions.e;
        this.f6752c = googleSignInOptions.f3352f;
        this.f6753d = googleSignInOptions.f3351d;
        this.e = googleSignInOptions.f3353m;
        this.f6754f = googleSignInOptions.f3350c;
        this.f6755g = googleSignInOptions.f3354n;
        this.f6756h = GoogleSignInOptions.d(googleSignInOptions.f3355o);
        this.f6757i = googleSignInOptions.f3356p;
    }
}
