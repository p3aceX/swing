package com.google.android.play.core.integrity;

import com.google.android.gms.common.api.Status;
import java.util.Locale;

/* JADX INFO: loaded from: classes.dex */
public class IntegrityServiceException extends com.google.android.gms.common.api.j {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    private final Throwable f3632a;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public IntegrityServiceException(int i4, Throwable th) {
        super(new Status(i4, "Integrity API error (" + i4 + "): " + com.google.android.play.core.integrity.model.a.a(i4) + "."));
        Locale locale = Locale.ROOT;
        if (i4 == 0) {
            throw new IllegalArgumentException("ErrorCode should not be 0.");
        }
        this.f3632a = th;
    }

    @Override // java.lang.Throwable
    public final synchronized Throwable getCause() {
        return this.f3632a;
    }

    public int getErrorCode() {
        return super.getStatusCode();
    }
}
