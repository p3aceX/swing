package g1;

import android.content.Context;
import android.text.TextUtils;
import com.google.android.gms.common.internal.F;
import com.google.android.gms.common.internal.r;
import java.util.Arrays;

/* JADX INFO: loaded from: classes.dex */
public final class j {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final String f4318a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final String f4319b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final String f4320c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final String f4321d;
    public final String e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final String f4322f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public final String f4323g;

    public j(String str, String str2, String str3, String str4, String str5, String str6, String str7) {
        int i4 = G0.c.f491a;
        F.i("ApplicationId must be set.", true ^ (str == null || str.trim().isEmpty()));
        this.f4319b = str;
        this.f4318a = str2;
        this.f4320c = str3;
        this.f4321d = str4;
        this.e = str5;
        this.f4322f = str6;
        this.f4323g = str7;
    }

    public static j a(Context context) {
        r rVar = new r(context, 1);
        String strA = rVar.A("google_app_id");
        if (TextUtils.isEmpty(strA)) {
            return null;
        }
        return new j(strA, rVar.A("google_api_key"), rVar.A("firebase_database_url"), rVar.A("ga_trackingId"), rVar.A("gcm_defaultSenderId"), rVar.A("google_storage_bucket"), rVar.A("project_id"));
    }

    public final boolean equals(Object obj) {
        if (!(obj instanceof j)) {
            return false;
        }
        j jVar = (j) obj;
        return F.j(this.f4319b, jVar.f4319b) && F.j(this.f4318a, jVar.f4318a) && F.j(this.f4320c, jVar.f4320c) && F.j(this.f4321d, jVar.f4321d) && F.j(this.e, jVar.e) && F.j(this.f4322f, jVar.f4322f) && F.j(this.f4323g, jVar.f4323g);
    }

    public final int hashCode() {
        return Arrays.hashCode(new Object[]{this.f4319b, this.f4318a, this.f4320c, this.f4321d, this.e, this.f4322f, this.f4323g});
    }

    public final String toString() {
        r rVar = new r(this);
        rVar.v(this.f4319b, "applicationId");
        rVar.v(this.f4318a, "apiKey");
        rVar.v(this.f4320c, "databaseUrl");
        rVar.v(this.e, "gcmSenderId");
        rVar.v(this.f4322f, "storageBucket");
        rVar.v(this.f4323g, "projectId");
        return rVar.toString();
    }
}
