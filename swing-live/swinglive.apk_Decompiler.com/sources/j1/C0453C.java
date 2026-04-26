package j1;

import android.text.TextUtils;
import android.util.Log;
import com.google.android.gms.internal.p002firebaseauthapi.zzaag;
import com.google.android.gms.tasks.Task;
import com.google.firebase.auth.FirebaseAuth;

/* JADX INFO: renamed from: j1.C, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0453C extends e1.k {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ String f5164a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ boolean f5165b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ l f5166c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final /* synthetic */ String f5167d;
    public final /* synthetic */ String e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final /* synthetic */ FirebaseAuth f5168f;

    public C0453C(FirebaseAuth firebaseAuth, String str, boolean z4, l lVar, String str2, String str3) {
        this.f5164a = str;
        this.f5165b = z4;
        this.f5166c = lVar;
        this.f5167d = str2;
        this.e = str3;
        this.f5168f = firebaseAuth;
    }

    /* JADX WARN: Multi-variable type inference failed */
    /* JADX WARN: Type inference failed for: r9v0, types: [j1.f, k1.p] */
    /* JADX WARN: Type inference fix 'apply assigned field type' failed
    java.lang.UnsupportedOperationException: ArgType.getObject(), call class: class jadx.core.dex.instructions.args.ArgType$UnknownArg
    	at jadx.core.dex.instructions.args.ArgType.getObject(ArgType.java:593)
    	at jadx.core.dex.attributes.nodes.ClassTypeVarsAttr.getTypeVarsMapFor(ClassTypeVarsAttr.java:35)
    	at jadx.core.dex.nodes.utils.TypeUtils.replaceClassGenerics(TypeUtils.java:177)
    	at jadx.core.dex.visitors.typeinference.FixTypesVisitor.insertExplicitUseCast(FixTypesVisitor.java:397)
    	at jadx.core.dex.visitors.typeinference.FixTypesVisitor.tryFieldTypeWithNewCasts(FixTypesVisitor.java:359)
    	at jadx.core.dex.visitors.typeinference.FixTypesVisitor.applyFieldType(FixTypesVisitor.java:309)
    	at jadx.core.dex.visitors.typeinference.FixTypesVisitor.visit(FixTypesVisitor.java:94)
     */
    @Override // e1.k
    public final Task R(String str) {
        boolean zIsEmpty = TextUtils.isEmpty(str);
        String str2 = this.f5164a;
        if (zIsEmpty) {
            Log.i("FirebaseAuth", "Logging in as " + str2 + " with empty reCAPTCHA token");
        } else {
            Log.i("FirebaseAuth", "Got reCAPTCHA token for login with email " + str2);
        }
        boolean z4 = this.f5165b;
        FirebaseAuth firebaseAuth = this.f5168f;
        if (!z4) {
            return firebaseAuth.e.zzb(firebaseAuth.f3841a, this.f5164a, this.f5167d, this.e, str, new C0462g(firebaseAuth));
        }
        zzaag zzaagVar = firebaseAuth.e;
        l lVar = this.f5166c;
        com.google.android.gms.common.internal.F.g(lVar);
        return zzaagVar.zzb(firebaseAuth.f3841a, lVar, this.f5164a, this.f5167d, this.e, str, new C0461f(firebaseAuth, 0));
    }
}
