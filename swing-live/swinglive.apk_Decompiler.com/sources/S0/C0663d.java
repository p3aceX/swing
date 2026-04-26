package s0;

import com.google.android.gms.common.api.e;
import com.google.android.gms.common.internal.F;
import com.google.android.gms.common.internal.r;
import java.util.Arrays;

/* JADX INFO: renamed from: s0.d, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0663d implements e {

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final C0663d f6475c;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final boolean f6476a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final String f6477b;

    static {
        r rVar = new r(20, false);
        rVar.f3597b = Boolean.FALSE;
        f6475c = new C0663d(rVar);
    }

    public C0663d(r rVar) {
        this.f6476a = ((Boolean) rVar.f3597b).booleanValue();
        this.f6477b = (String) rVar.f3598c;
    }

    public final boolean equals(Object obj) {
        if (obj == this) {
            return true;
        }
        if (!(obj instanceof C0663d)) {
            return false;
        }
        C0663d c0663d = (C0663d) obj;
        c0663d.getClass();
        return F.j(null, null) && this.f6476a == c0663d.f6476a && F.j(this.f6477b, c0663d.f6477b);
    }

    public final int hashCode() {
        return Arrays.hashCode(new Object[]{null, Boolean.valueOf(this.f6476a), this.f6477b});
    }
}
