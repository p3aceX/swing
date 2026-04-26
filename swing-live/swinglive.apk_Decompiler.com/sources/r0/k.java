package R0;

import android.util.Base64;
import b1.C0243a;
import com.google.android.gms.internal.p002firebaseauthapi.zzah;
import com.google.android.gms.tasks.Task;
import com.google.android.recaptcha.RecaptchaAction;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthRegistrar;
import d1.Z;
import d1.f0;
import d1.r0;
import java.nio.ByteBuffer;
import java.security.GeneralSecurityException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import l1.C0522a;
import l1.r;
import l1.s;
import o1.InterfaceC0580a;
import q1.InterfaceC0634a;
import u1.C0690c;

/* JADX INFO: loaded from: classes.dex */
public final class k implements l1.d, l1.b {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f1690a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public Object f1691b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public Object f1692c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public Object f1693d;
    public Object e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public Object f1694f;

    public /* synthetic */ k(int i4) {
        this.f1690a = i4;
    }

    @Override // l1.b
    public Object a(Class cls) {
        if (!((Set) this.f1691b).contains(r.a(cls))) {
            throw new A0.b("Attempting to request an undeclared dependency " + cls + ".");
        }
        Object objA = ((l1.b) this.f1694f).a(cls);
        if (!cls.equals(InterfaceC0580a.class)) {
            return objA;
        }
        return new s();
    }

    @Override // l1.b
    public Object b(r rVar) {
        if (((Set) this.f1691b).contains(rVar)) {
            return ((l1.b) this.f1694f).b(rVar);
        }
        throw new A0.b("Attempting to request an undeclared dependency " + rVar + ".");
    }

    @Override // l1.b
    public InterfaceC0634a c(Class cls) {
        return f(r.a(cls));
    }

    @Override // l1.b
    public Set d(r rVar) {
        if (((Set) this.f1693d).contains(rVar)) {
            return ((l1.b) this.f1694f).d(rVar);
        }
        throw new A0.b("Attempting to request an undeclared dependency Set<" + rVar + ">.");
    }

    @Override // l1.d
    public Object e(k kVar) {
        return FirebaseAuthRegistrar.lambda$getComponents$0((r) this.f1691b, (r) this.f1692c, (r) this.f1693d, (r) this.e, (r) this.f1694f, kVar);
    }

    @Override // l1.b
    public InterfaceC0634a f(r rVar) {
        if (((Set) this.f1692c).contains(rVar)) {
            return ((l1.b) this.f1694f).f(rVar);
        }
        throw new A0.b("Attempting to request an undeclared dependency Provider<" + rVar + ">.");
    }

    @Override // l1.b
    public InterfaceC0634a g(r rVar) {
        if (((Set) this.e).contains(rVar)) {
            return ((l1.b) this.f1694f).g(rVar);
        }
        throw new A0.b("Attempting to request an undeclared dependency Provider<Set<" + rVar + ">>.");
    }

    public void h(Object obj, Object obj2, f0 f0Var, boolean z4) {
        byte[] bArrArray;
        if (((ConcurrentHashMap) this.f1692c) == null) {
            throw new IllegalStateException("addPrimitive cannot be called after build");
        }
        if (obj == null && obj2 == null) {
            throw new GeneralSecurityException("at least one of the `fullPrimitive` or `primitive` must be set");
        }
        if (f0Var.D() != Z.ENABLED) {
            throw new GeneralSecurityException("only ENABLED key is allowed");
        }
        Integer numValueOf = Integer.valueOf(f0Var.B());
        if (f0Var.C() == r0.RAW) {
            numValueOf = null;
        }
        b bVarA = Y0.h.f2478b.a(Y0.n.b(f0Var.A().B(), f0Var.A().C(), f0Var.A().A(), f0Var.C(), numValueOf));
        int iOrdinal = f0Var.C().ordinal();
        if (iOrdinal == 1) {
            bArrArray = ByteBuffer.allocate(5).put((byte) 1).putInt(f0Var.B()).array();
        } else if (iOrdinal == 2) {
            bArrArray = ByteBuffer.allocate(5).put((byte) 0).putInt(f0Var.B()).array();
        } else if (iOrdinal != 3) {
            if (iOrdinal != 4) {
                throw new GeneralSecurityException("unknown output prefix type");
            }
            bArrArray = ByteBuffer.allocate(5).put((byte) 0).putInt(f0Var.B()).array();
        } else {
            bArrArray = b.f1679a;
        }
        l lVar = new l(obj, obj2, bArrArray, f0Var.D(), f0Var.C(), f0Var.B(), f0Var.A().B(), bVarA);
        ConcurrentHashMap concurrentHashMap = (ConcurrentHashMap) this.f1692c;
        ArrayList arrayList = (ArrayList) this.f1693d;
        ArrayList arrayList2 = new ArrayList();
        arrayList2.add(lVar);
        byte[] bArr = lVar.f1697c;
        m mVar = new m(bArr != null ? Arrays.copyOf(bArr, bArr.length) : null);
        List list = (List) concurrentHashMap.put(mVar, Collections.unmodifiableList(arrayList2));
        if (list != null) {
            ArrayList arrayList3 = new ArrayList();
            arrayList3.addAll(list);
            arrayList3.add(lVar);
            concurrentHashMap.put(mVar, Collections.unmodifiableList(arrayList3));
        }
        arrayList.add(lVar);
        if (z4) {
            if (((l) this.e) != null) {
                throw new IllegalStateException("you cannot set two primary primitives");
            }
            this.e = lVar;
        }
    }

    public S0.k i() {
        if (((Integer) this.f1691b) == null) {
            throw new GeneralSecurityException("AES key size is not set");
        }
        if (((Integer) this.f1692c) == null) {
            throw new GeneralSecurityException("HMAC key size is not set");
        }
        Integer num = (Integer) this.f1693d;
        if (num == null) {
            throw new GeneralSecurityException("tag size is not set");
        }
        if (((S0.j) this.e) == null) {
            throw new GeneralSecurityException("hash type is not set");
        }
        if (((S0.j) this.f1694f) == null) {
            throw new GeneralSecurityException("variant is not set");
        }
        int iIntValue = num.intValue();
        S0.j jVar = (S0.j) this.e;
        if (jVar == S0.j.f1737c) {
            if (iIntValue > 20) {
                throw new GeneralSecurityException(String.format("Invalid tag size in bytes %d; can be at most 20 bytes for SHA1", num));
            }
        } else if (jVar == S0.j.f1738d) {
            if (iIntValue > 28) {
                throw new GeneralSecurityException(String.format("Invalid tag size in bytes %d; can be at most 28 bytes for SHA224", num));
            }
        } else if (jVar == S0.j.e) {
            if (iIntValue > 32) {
                throw new GeneralSecurityException(String.format("Invalid tag size in bytes %d; can be at most 32 bytes for SHA256", num));
            }
        } else if (jVar == S0.j.f1739f) {
            if (iIntValue > 48) {
                throw new GeneralSecurityException(String.format("Invalid tag size in bytes %d; can be at most 48 bytes for SHA384", num));
            }
        } else {
            if (jVar != S0.j.f1740g) {
                throw new GeneralSecurityException("unknown hash type; must be SHA1, SHA224, SHA256, SHA384 or SHA512");
            }
            if (iIntValue > 64) {
                throw new GeneralSecurityException(String.format("Invalid tag size in bytes %d; can be at most 64 bytes for SHA512", num));
            }
        }
        return new S0.k(((Integer) this.f1691b).intValue(), ((Integer) this.f1692c).intValue(), ((Integer) this.f1693d).intValue(), (S0.j) this.f1694f, (S0.j) this.e);
    }

    public Task j(String str, Boolean bool, RecaptchaAction recaptchaAction) {
        Task taskContinueWithTask;
        if (zzah.zzc(str)) {
            str = "*";
        }
        Task task = (Task) ((HashMap) this.f1691b).get(str);
        if (bool.booleanValue() || task == null) {
            String str2 = zzah.zzc(str) ? "*" : str;
            if (bool.booleanValue() || (taskContinueWithTask = (Task) ((HashMap) this.f1691b).get(str2)) == null) {
                FirebaseAuth firebaseAuth = (FirebaseAuth) this.e;
                taskContinueWithTask = firebaseAuth.e.zza(firebaseAuth.f3848i, "RECAPTCHA_ENTERPRISE").continueWithTask(new com.google.android.gms.common.internal.r(this, str2));
            }
            task = taskContinueWithTask;
        }
        return task.continueWithTask(new C0690c(recaptchaAction, 29));
    }

    public String toString() {
        switch (this.f1690a) {
            case 5:
                StringBuilder sb = new StringBuilder();
                sb.append("FontRequest {mProviderAuthority: " + ((String) this.f1691b) + ", mProviderPackage: " + ((String) this.f1692c) + ", mQuery: " + ((String) this.f1693d) + ", mCertificates:");
                int i4 = 0;
                while (true) {
                    List list = (List) this.e;
                    if (i4 >= list.size()) {
                        sb.append("}mCertificatesArray: 0");
                        return sb.toString();
                    }
                    sb.append(" [");
                    List list2 = (List) list.get(i4);
                    for (int i5 = 0; i5 < list2.size(); i5++) {
                        sb.append(" \"");
                        sb.append(Base64.encodeToString((byte[]) list2.get(i5), 0));
                        sb.append("\"");
                    }
                    sb.append(" ]");
                    i4++;
                }
                break;
            default:
                return super.toString();
        }
    }

    public k(C0522a c0522a, l1.b bVar) {
        this.f1690a = 4;
        HashSet hashSet = new HashSet();
        HashSet hashSet2 = new HashSet();
        HashSet hashSet3 = new HashSet();
        HashSet hashSet4 = new HashSet();
        HashSet hashSet5 = new HashSet();
        for (l1.j jVar : c0522a.f5590b) {
            int i4 = jVar.f5613c;
            boolean z4 = i4 == 0;
            int i5 = jVar.f5612b;
            r rVar = jVar.f5611a;
            if (z4) {
                if (i5 == 2) {
                    hashSet4.add(rVar);
                } else {
                    hashSet.add(rVar);
                }
            } else if (i4 == 2) {
                hashSet3.add(rVar);
            } else if (i5 == 2) {
                hashSet5.add(rVar);
            } else {
                hashSet2.add(rVar);
            }
        }
        if (!c0522a.e.isEmpty()) {
            hashSet.add(r.a(InterfaceC0580a.class));
        }
        this.f1691b = Collections.unmodifiableSet(hashSet);
        this.f1692c = Collections.unmodifiableSet(hashSet2);
        Collections.unmodifiableSet(hashSet3);
        this.f1693d = Collections.unmodifiableSet(hashSet4);
        this.e = Collections.unmodifiableSet(hashSet5);
        this.f1694f = bVar;
    }

    public k(String str, String str2, String str3, List list) {
        this.f1690a = 5;
        this.f1691b = str;
        this.f1692c = str2;
        this.f1693d = str3;
        list.getClass();
        this.e = list;
        this.f1694f = str + "-" + str2 + "-" + str3;
    }

    public k(Class cls) {
        this.f1690a = 0;
        this.f1692c = new ConcurrentHashMap();
        this.f1693d = new ArrayList();
        this.f1691b = cls;
        this.f1694f = C0243a.f3269b;
    }
}
