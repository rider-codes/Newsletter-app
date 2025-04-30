import React, { useState } from 'react';

interface NewsletterFormProps {
  onSubmit?: (success: boolean) => void;
}

const NewsletterForm: React.FC<NewsletterFormProps> = ({ onSubmit }) => {
  const [recipients, setRecipients] = useState('');
  const [loading, setLoading] = useState(false);
  const [result, setResult] = useState<{ success: boolean; message: string } | null>(null);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setResult(null);

    try {
      const recipientList = recipients.split(',').map(email => email.trim());
      
      const response = await fetch('https://6k4ijo36te.execute-api.us-east-1.amazonaws.com/prod/send-newsletter', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          recipients: recipientList,
        }),
      });

      const data = await response.json();
      
      if (response.ok) {
        setResult({
          success: true,
          message: `Successfully sent to ${data.emails_sent} recipients${data.errors ? `. Errors: ${data.errors.join(', ')}` : ''}`,
        });
        if (onSubmit) onSubmit(true);
      } else {
        setResult({
          success: false,
          message: data.message || 'Failed to send to recipients',
        });
        if (onSubmit) onSubmit(false);
      }
    } catch (error) {
      setResult({
        success: false,
        message: error instanceof Error ? error.message : 'An error occurred',
      });
      if (onSubmit) onSubmit(false);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="max-w-4xl mx-auto p-8">
      <div className="space-y-8">
        <div>
          <h2 className="text-2xl font-bold text-gray-900">Email Recipients</h2>
          <p className="mt-1 text-sm text-gray-600">
            Add email addresses for your recipients.
          </p>
        </div>

        <form onSubmit={handleSubmit} className="space-y-6">
          <div className="bg-white shadow-sm ring-1 ring-gray-900/5 rounded-xl p-6">
            <div>
              <label htmlFor="recipients" className="block text-sm font-medium leading-6 text-gray-900">
                Recipients
              </label>
              <div className="mt-2">
                <textarea
                  id="recipients"
                  value={recipients}
                  onChange={(e) => setRecipients(e.target.value)}
                  rows={6}
                  className="block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm sm:leading-6"
                  placeholder="Enter email addresses separated by commas&#10;e.g., john@example.com, jane@example.com"
                  required
                />
                <p className="mt-2 text-sm text-gray-500">
                  Separate multiple email addresses with commas.
                </p>
              </div>
            </div>
          </div>

          <div className="flex items-center justify-end gap-x-6">
            <button
              type="button"
              onClick={() => {
                setRecipients('');
                setResult(null);
              }}
              className="text-sm font-semibold leading-6 text-gray-900 hover:text-gray-700"
            >
              Clear
            </button>
            <button
              type="submit"
              disabled={loading}
              className={`rounded-md px-6 py-2.5 text-sm font-semibold text-white shadow-sm transition-all duration-200 ${
                loading
                  ? 'bg-indigo-400 cursor-not-allowed'
                  : 'bg-indigo-600 hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600'
              }`}
            >
              {loading ? (
                <div className="flex items-center gap-2">
                  <svg className="animate-spin h-4 w-4 text-white" fill="none" viewBox="0 0 24 24">
                    <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                    <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                  </svg>
                  <span>Sending...</span>
                </div>
              ) : (
                'Send'
              )}
            </button>
          </div>
        </form>

        {result && (
          <div
            className={`mt-6 p-4 rounded-lg border ${
              result.success
                ? 'bg-green-50 border-green-200 text-green-800'
                : 'bg-red-50 border-red-200 text-red-800'
            }`}
          >
            <div className="flex">
              <div className="flex-shrink-0">
                {result.success ? (
                  <svg className="h-5 w-5 text-green-400" viewBox="0 0 20 20" fill="currentColor">
                    <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd" />
                  </svg>
                ) : (
                  <svg className="h-5 w-5 text-red-400" viewBox="0 0 20 20" fill="currentColor">
                    <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clipRule="evenodd" />
                  </svg>
                )}
              </div>
              <div className="ml-3">
                <p className="text-sm font-medium">{result.message}</p>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default NewsletterForm; 