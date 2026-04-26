package O0;

import com.google.android.gms.common.api.e;
import com.google.android.gms.common.internal.F;
import java.util.Arrays;

/* JADX INFO: loaded from: classes.dex */
public final class a implements e {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final a f1441a = new a();

    public final boolean equals(Object obj) {
        if (obj == this) {
            return true;
        }
        if (!(obj instanceof a)) {
            return false;
        }
        ((a) obj).getClass();
        return F.j(null, null) && F.j(null, null) && F.j(null, null) && F.j(null, null) && F.j(null, null);
    }

    public final int hashCode() {
        Boolean bool = Boolean.FALSE;
        return Arrays.hashCode(new Object[]{bool, bool, null, bool, bool, null, null, null, null});
    }
}
