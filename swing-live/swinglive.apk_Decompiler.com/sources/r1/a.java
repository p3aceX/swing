package r1;

import com.google.android.gms.common.internal.F;
import com.google.android.gms.common.internal.r;
import java.util.Arrays;

/* JADX INFO: loaded from: classes.dex */
public final class a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public String f6306a;

    public final boolean equals(Object obj) {
        if (obj instanceof a) {
            return F.j(this.f6306a, ((a) obj).f6306a);
        }
        return false;
    }

    public final int hashCode() {
        return Arrays.hashCode(new Object[]{this.f6306a});
    }

    public final String toString() {
        r rVar = new r(this);
        rVar.v(this.f6306a, "token");
        return rVar.toString();
    }
}
